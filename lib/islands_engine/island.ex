defmodule IslandsEngine.Island do
  alias __MODULE__
  alias IslandsEngine.Coordinate

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct coordinates: nil, hit_coordinates: nil

  @type t(coordinates, hit_coordinates) :: %__MODULE__{
          coordinates: coordinates,
          hit_coordinates: hit_coordinates
        }
  @type t :: %__MODULE__{
          coordinates: Coordinate.coordinates(),
          hit_coordinates: Coordinate.coordinates()
        }

  @typep island_type :: :square | :atoll | :dot | :l_shape | :s_shape

  @spec new :: Island.t()
  def new(),
    do: %__MODULE__{coordinates: MapSet.new(), hit_coordinates: MapSet.new()}

  @doc """
  `with`句の正常時のコードについて、本来は↓のコードだが、このままではDialyxirのエラーを解消できなかった。

  ```elixir
  %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
  ```
  このコードから`%MapSet{} = coordinates`から`%MapSet{} =`を除外すると
  Dialyxirのエラーは解消できたが、エラー発生時に`coordinates`にそのままエラー結果が入ってしまう。

  そのため、`:ok`を付与して明示的に正常に動作した場合の`Coordinate`を取得するように修正した。

  いまのところうまく動作しているように見える。
  """
  @spec new(island_type(), Coordinate.t()) ::
          {:error, :invalid_coordinate} | {:ok, Island.t()}
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         {:ok, coordinates} <- add_coordinates(offsets, upper_left) do
      {:ok, %__MODULE__{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @spec offsets(island_type()) :: [Coordinate.offset()]
  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  @spec add_coordinates([Coordinate.offset()], Coordinate.t()) ::
          {:ok, Coordinate.coordinates()} | {:error, :invalid_coordinate}
  defp add_coordinates(offsets, upper_left) do
    result_reduce_while =
      Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
        add_coordinate(acc, upper_left, offset)
      end)

    # Dialyxirのエラーをどうにも解消できないので、`reduce_while`の結果を`:ok`を付与した。
    case result_reduce_while do
      {:error, _} = error -> error
      acc -> {:ok, acc}
    end
  end

  @spec add_coordinate(
          Coordinate.coordinates(),
          Coordinate.t(),
          Coordinate.offset()
        ) ::
          {:cont, Coordinate.coordinates()} | {:halt, :invalid_coordinate}
  defp add_coordinate(
         coordinates,
         %Coordinate{row: row, col: col},
         {row_offset, col_offset}
       ) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} -> {:halt, {:error, :invalid_coordinate}}
    end
  end
end
