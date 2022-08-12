defmodule IslandsEngine.Rules do
  alias IslandsEngine.Board

  @enforce_keys [:state]
  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  @type game_state ::
          :initialized
          | :players_set
          | :player1_turn
          | :player2_turn
          | :game_over

  @type player_state :: :islands_set | :islands_not_set

  @type t :: %__MODULE__{
          state: game_state(),
          player1: player_state(),
          player2: player_state()
        }

  @typep player :: :player1 | :player2

  @spec new :: __MODULE__.t()
  def new(), do: %__MODULE__{state: :initialized}

  @type action ::
          :add_player
          | {:position_islands, player_state()}
          | {:set_islands, player_state()}
          | {:guess_coordinate, player()}
          | {:win_check, Board.win_or_not()}

  @spec check(__MODULE__.t(), action()) :: :error | {:ok, __MODULE__.t()}
  def check(%__MODULE__{state: :initialized} = rules, :add_player) do
    {:ok, %__MODULE__{rules | state: :players_set}}
  end

  def check(%__MODULE__{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%__MODULE__{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_islands_set?(rules) do
      true -> {:ok, %__MODULE__{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  def check(%__MODULE__{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %__MODULE__{rules | state: :player2_turn}}
  end

  def check(%__MODULE__{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %__MODULE__{rules | state: :player1_turn}}
  end

  # def check(%__MODULE__{state: :player1_turn} = rules, {:win_check, win_or_not}) do
  #   case win_or_not do
  #     :no_win -> {:ok, rules}
  #     :win -> {:ok, %__MODULE__{rules | state: :game_over}}
  #   end
  # end

  # def check(%__MODULE__{state: :player2_turn} = rules, {:win_check, win_or_not}) do
  #   case win_or_not do
  #     :no_win -> {:ok, rules}
  #     :win -> {:ok, %__MODULE__{rules | state: :game_over}}
  #   end
  # end

  # 同じロジックになっていたので`when`で対処する。
  # ↑のコメントアウトしているものが書籍で提示されているコード。
  def check(rules, {:win_check, win_or_not})
      when rules.state == :player1_turn or rules.state == :player2_turn do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %__MODULE__{rules | state: :game_over}}
    end
  end

  # こちらの定義を先に持ってくるとエラーになる。
  def check(_state, _action) do
    :error
  end

  @spec both_players_islands_set?(__MODULE__.t()) :: boolean()
  defp both_players_islands_set?(rules),
    do: rules.player1 == :islands_set && rules.player2 == :islands_set
end
