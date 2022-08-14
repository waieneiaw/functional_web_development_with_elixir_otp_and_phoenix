defmodule IslandsEngine.Game do
  use GenServer

  # ステート更新（`:sys.replace_state`）を実行する場合、`Access`ビヘイビアを実装しなければならない。
  # なお、書籍では一切言及されていないので、`defstruct`しなければもしかしたら不要なのかもしれない。
  @behaviour Access

  # Guardはrequireかimportしないと使えない。Guardは実質マクロらしい。
  # importで呼び出す場合は↓の書き方でOK。
  # ```elixir
  # import IslandsEngine.Player, only: [is_role: 1]
  # ```
  # requireは呼び出し元のモジュールよりも前にコンパイルされていることを保証するらしい。
  # requireであれば名前空間もつけて呼び出せるので、importではなくrequireで実装する。
  require IslandsEngine.Player

  alias IslandsEngine.{Board, Coordinate, Guesses, Island, Player, Rules}

  @enforce_keys [:player1, :player2, :rules]
  defstruct @enforce_keys

  @typep t :: %__MODULE__{
           player1: Player.t(),
           player2: Player.t(),
           rules: Rules.t()
         }

  # GenServerから受け取るプロセス。
  # どういう名前が適切かわからなかったので`GenServer.on_start()`をそのまま再定義する。
  @typep game_process :: GenServer.on_start()

  # `handle_call/3`の`from`用の型。たぶん必要はなさそう。
  # これ自身を使うことはないので、ただ自分がわかりやすいように書いている。
  @typep caller :: {pid, term}

  @typedoc """
  `handle_call/3`の戻り値の型。
  今回は`:reply`だけでかつステートの型は決まっているので、第２引数の`term`だけ自由に設定できるよう定義する。
  こんなふうに関数化できるのは便利だが、この引数自体が曖昧になるので多用しない方が良さそう。
  """
  @type handle_call_return_type(reply_data) :: {:reply, reply_data, __MODULE__.t()}

  # ----------------------------------------------------------------------------
  # GenServer callbacks
  # ----------------------------------------------------------------------------

  @spec init(Player.name()) :: {:ok, __MODULE__.t()}
  def init(name) do
    {:ok, %__MODULE__{player1: Player.new(name), player2: Player.new(), rules: %Rules{}}}
  end

  @spec start_link(Player.name()) :: game_process()
  def start_link(name) when is_binary(name),
    do: GenServer.start_link(__MODULE__, name, [])

  @spec add_player(game_process(), Player.name()) :: :ok | :error
  def add_player(game, name) when is_binary(name),
    do: GenServer.call(game, {:add_player, name})

  @spec handle_call({:add_player, Player.name()}, caller(), __MODULE__.t()) ::
          handle_call_return_type(:ok | :error)
  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player) do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  @spec handle_call(
          {
            :position_island,
            Player.role(),
            Island.island_type(),
            Coordinate.row(),
            Coordinate.col()
          },
          caller(),
          __MODULE__.t()
        ) ::
          handle_call_return_type(
            :ok
            | :error
            | {:error, :invalid_coordinate}
            | {:error, :overlapping_island}
          )
  def handle_call({:position_island, player, key, row, col}, _from, state_data) do
    board = player_board(state_data, player)

    with {:ok, rules} <- Rules.check(state_data.rules, {:position_islands, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(key, coordinate),
         %{} = board <- Board.position_island(board, key, island) do
      state_data
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
      {:error, :invalid_coordinate} -> {:reply, {:error, :invalid_coordinate}, state_data}
      # 書籍では`invalid_island_type`だが実際は`overlapping_island`が正しい？
      {:error, :overlapping_island} -> {:reply, {:error, :overlapping_island}, state_data}
    end
  end

  @spec handle_call({:set_islands, Player.role()}, caller(), __MODULE__.t()) ::
          handle_call_return_type(
            {:ok, Board.t()}
            | :error
            | {:error, :not_all_islands_positioned}
          )
  def handle_call({:set_islands, player}, _from, state_data) do
    board = player_board(state_data, player)

    with {:ok, rules} <- Rules.check(state_data.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board) do
      state_data
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error -> {:reply, :error, state_data}
      false -> {:reply, {:error, :not_all_islands_positioned}, state_data}
    end
  end

  @spec handle_call(
          {:guess_coordinate, Player.name(), Coordinate.row(), Coordinate.col()},
          caller(),
          __MODULE__.t()
        ) ::
          handle_call_return_type(
            {Guesses.hit_or_miss(), :none | Island.island_type(), Board.win_or_not()}
            | :error
            | {:error, :invalid_coordinate}
          )
  def handle_call({:guess_coordinate, player_key, row, col}, _from, state_data) do
    opponent_key = opponent(player_key)
    opponent_board = player_board(state_data, player_key)

    with {:ok, rules} <- Rules.check(state_data.rules, {:guess_coordinate, player_key}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coordinate),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state_data
      |> update_board(opponent_key, opponent_board)
      |> update_guesses(player_key, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> {:reply, :error, state_data}
      {:error, :invalid_coordinate} -> {:reply, {:error, :invalid_coordinate}, state_data}
    end
  end

  # ----------------------------------------------------------------------------
  # Access callbacks
  #
  # `:sys.replace_state`を実行するために仕方なく定義する。
  # マップ操作をしたいだけなので、特にひねらず、そのまま`Map.~~~`に渡す。
  # ----------------------------------------------------------------------------

  def get_and_update(data, key, function) do
    Map.get_and_update(data, key, function)
  end

  def pop(data, key) do
    Map.pop(data, key)
  end

  def fetch(term, key) do
    Map.fetch(term, key)
  end

  # ----------------------------------------------------------------------------
  # public functions
  # ----------------------------------------------------------------------------

  @spec position_island(
          game_process(),
          Player.role(),
          Island.island_type(),
          Coordinate.row(),
          Coordinate.col()
        ) :: :ok | :error
  def position_island(game, player, key, row, col) when Player.is_role(player),
    do: GenServer.call(game, {:position_island, player, key, row, col})

  @spec set_islands(game_process(), Player.role()) :: :ok | :error
  def set_islands(game, player) when Player.is_role(player),
    do: GenServer.call(game, {:set_islands, player})

  @spec guess_coordinate(game_process(), Player.role(), Coordinate.row(), Coordinate.col()) ::
          :ok | :error
  def guess_coordinate(game, player, row, col) when Player.is_role(player),
    do: GenServer.call(game, {:guess_coordinate, player, row, col})

  # ----------------------------------------------------------------------------
  # private functions
  # ----------------------------------------------------------------------------

  @spec update_player2_name(__MODULE__.t(), Player.name()) :: __MODULE__.t()
  defp update_player2_name(state_data, name),
    do: put_in(state_data.player2.name, name)

  @spec update_rules(__MODULE__.t(), Rules.t()) :: __MODULE__.t()
  defp update_rules(state_data, rules),
    do: %__MODULE__{state_data | rules: rules}

  @spec reply_success(__MODULE__.t(), term) :: {:reply, term, __MODULE__.t()}
  defp reply_success(state_data, reply),
    do: {:reply, reply, state_data}

  @spec player_board(__MODULE__.t(), Player.role()) :: Board.t()
  defp player_board(state_data, player),
    do: Map.get(state_data, player).board

  @spec update_board(__MODULE__.t(), Player.role(), Board.t()) :: __MODULE__.t()
  defp update_board(state_data, player, board),
    do: Map.update!(state_data, player, fn player -> %Player{player | board: board} end)

  @spec opponent(Player.role()) :: Player.role()
  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  @spec update_guesses(__MODULE__.t(), Player.role(), Guesses.hit_or_miss(), Coordinate.t()) ::
          __MODULE__.t()
  defp update_guesses(state_data, player_key, hit_or_miss, coordinate) do
    update_in(state_data[player_key].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end
end
