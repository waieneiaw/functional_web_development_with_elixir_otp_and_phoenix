defmodule IslandsEngineTest.Island do
  use ExUnit.Case

  alias IslandsEngine.{Coordinate, Guesses, Island}

  test "make :square coordinate" do
    row = 1
    col = 1

    {row_offset, col_offset} = {0, 0}

    {:ok, coordinate1} = Coordinate.new(row + row_offset, col + col_offset)

    assert coordinate1 == %Coordinate{col: 1, row: 1}

    offsets = [{0, 0}, {0, 1}, {1, 0}, {1, 1}]

    assert Enum.map(offsets, fn {row_offset, col_offset} ->
             Coordinate.new(row + row_offset, col + col_offset)
           end) == [
             {:ok, %Coordinate{col: 1, row: 1}},
             {:ok, %Coordinate{col: 2, row: 1}},
             {:ok, %Coordinate{col: 1, row: 2}},
             {:ok, %Coordinate{col: 2, row: 2}}
           ]
  end

  test "make :l_shape island" do
    {:ok, coordinate} = Coordinate.new(4, 6)

    assert Island.new(:l_shape, coordinate) ==
             {:ok,
              %Island{
                coordinates:
                  MapSet.new([
                    %Coordinate{col: 6, row: 4},
                    %Coordinate{col: 6, row: 5},
                    %Coordinate{col: 6, row: 6},
                    %Coordinate{col: 7, row: 6}
                  ]),
                hit_coordinates: MapSet.new([])
              }}
  end

  test "invalid island type" do
    {:ok, coordinate} = Coordinate.new(4, 6)

    assert Island.new(:wrong, coordinate) == {:error, :invalid_island_type}
  end

  test "invalid coordinate" do
    {:ok, coordinate} = Coordinate.new(10, 10)

    assert Island.new(:l_shape, coordinate) == {:error, :invalid_coordinate}
  end
end
