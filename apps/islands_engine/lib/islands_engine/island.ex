defmodule IslandsEngine.Island do
  alias IslandsEngine.Coordinate

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct @enforce_keys

  @type t(coordinates, hit_coordinates) :: %__MODULE__{
          coordinates: coordinates,
          hit_coordinates: hit_coordinates
        }
  @type t :: %__MODULE__{
          coordinates: Coordinate.coordinates(),
          hit_coordinates: Coordinate.coordinates()
        }

  @type island_type :: :square | :atoll | :dot | :l_shape | :s_shape

  @type hit_or_miss :: :hit | :miss

  @spec types() :: [island_type()]
  def types(), do: [:atoll, :dot, :l_shape, :s_shape, :square]

  @spec new :: __MODULE__.t()
  def new(),
    do: %__MODULE__{coordinates: MapSet.new(), hit_coordinates: MapSet.new()}

  @spec new(island_type(), Coordinate.t()) ::
          {:error, :invalid_coordinate} | {:ok, __MODULE__.t()}
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         # `with`句の正常時のコードについて、本来は↓のコードだが、
         # このままではDialyxirのエラーを解消できなかった。
         #
         # ```elixir
         # %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
         # ```
         # このコードから`%MapSet{} = coordinates`から`%MapSet{} =`を除外すると
         # Dialyxirのエラーは解消できたが、エラー発生時に`coordinates`にそのままエラー結果が入ってしまう。
         #
         # そのため、`:ok`を付与して明示的に正常に動作した場合の`Coordinate`を取得するように修正した。
         #
         # いまのところうまく動作しているように見える。
         {:ok, coordinates} <- add_coordinates(offsets, upper_left) do
      {:ok, %__MODULE__{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @spec overlaps?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  @spec guess(__MODULE__.t(), Coordinate.t()) :: {:hit, __MODULE__.t()} | :miss
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @spec forested?(__MODULE__.t()) :: boolean()
  def forested?(island),
    do: MapSet.equal?(island.coordinates, island.hit_coordinates)

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

    case result_reduce_while do
      {:error, _} = error -> error
      # Dialyxirのエラーをどうにも解消できないので、`reduce_while`の成功した結果に`:ok`を付与した。
      coordinates -> {:ok, coordinates}
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
