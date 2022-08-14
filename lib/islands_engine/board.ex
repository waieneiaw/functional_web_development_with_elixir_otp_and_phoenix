defmodule IslandsEngine.Board do
  alias IslandsEngine.{Island, Coordinate}

  # ソースを読む限り、おそらくキーから`Island`を取る形に読めるので、↓URLを参考に以下の形に設定してみた。
  # https://hexdocs.pm/elixir/1.14.0-rc.0/typespecs.html#maps
  @type t() :: %{optional(Island.island_type()) => Island.t()}

  @type win_or_not :: :win | :no_win

  @doc """
  動的にkeyを設定するStructは`defstruct`で定義できないらしい。
  なので、型定義はしているものの実態は`Board`型として機能しないので、この点は注意が必要かもしれない。
  """
  @spec new :: __MODULE__.t()
  def new(), do: %{}

  @spec position_island(__MODULE__.t(), Island.island_type(), IslandsEngine.Island.t()) ::
          {:error, :overlapping_island} | __MODULE__.t()
  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  @spec all_islands_positioned?(__MODULE__.t()) :: boolean()
  def all_islands_positioned?(board),
    do: Enum.all?(Island.types(), &Map.has_key?(board, &1))

  @spec guess(__MODULE__.t(), Coordinate.t()) ::
          {Island.hit_or_miss(), :none | Island.island_type(), win_or_not(), __MODULE__.t()}
  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  @spec overlaps_existing_island?(__MODULE__.t(), Island.island_type(), Island.t()) :: boolean()
  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  @spec check_all_islands(__MODULE__.t(), Coordinate.t()) ::
          :miss | {Island.island_type(), Island.t()}
  defp check_all_islands(board, coordinate) do
    # `Enum.find_value/3`の第２引数はデフォルト値。
    # `guess/2`が`:miss`を返した場合は`false`を`Enum.find_value/3`に返す。
    # `find`されなかったというなのでデフォルト値が採用され、この関数の戻り値が`:miss`になる。
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  @spec guess_response({:hit, Island.t()}, __MODULE__.t()) ::
          {:hit, Island.island_type(), :win, __MODULE__.t()}
  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  @spec guess_response(:miss, board :: __MODULE__.t()) ::
          {:miss, :none, :no_win, __MODULE__.t()}
  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  @spec forest_check(__MODULE__.t(), Island.island_type()) :: Island.island_type() | :none
  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  @spec forested?(__MODULE__.t(), Island.island_type()) :: boolean()
  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  @spec win_check(__MODULE__.t()) :: win_or_not()
  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  @spec all_forested?(__MODULE__.t()) :: boolean()
  defp all_forested?(board) do
    Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)
  end
end
