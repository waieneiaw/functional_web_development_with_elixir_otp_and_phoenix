defmodule IslandsEngineTest.Island do
  use ExUnit.Case

  alias IslandsEngine.{Coordinate, Island}

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

  test "overlaps?" do
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    assert square == %Island{
             coordinates:
               MapSet.new([
                 %Coordinate{col: 1, row: 1},
                 %Coordinate{col: 1, row: 2},
                 %Coordinate{col: 2, row: 1},
                 %Coordinate{col: 2, row: 2}
               ]),
             hit_coordinates: MapSet.new()
           }

    {:ok, dot_coordinate} = Coordinate.new(1, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    assert dot == %Island{
             coordinates: MapSet.new([%Coordinate{col: 2, row: 1}]),
             hit_coordinates: MapSet.new()
           }

    {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

    assert l_shape == %Island{
             coordinates:
               MapSet.new([
                 %Coordinate{col: 5, row: 5},
                 %Coordinate{col: 5, row: 6},
                 %Coordinate{col: 5, row: 7},
                 %Coordinate{col: 6, row: 7}
               ]),
             hit_coordinates: MapSet.new()
           }

    assert Island.overlaps?(square, dot) == true
    assert Island.overlaps?(square, l_shape) == false
    assert Island.overlaps?(dot, l_shape) == false
  end

  test "guess and forested?" do
    {:ok, dot_coodinate} = Coordinate.new(4, 4)
    {:ok, dot} = Island.new(:dot, dot_coodinate)

    assert dot == %Island{
             coordinates: MapSet.new([%Coordinate{col: 4, row: 4}]),
             hit_coordinates: MapSet.new()
           }

    {:ok, coordinate} = Coordinate.new(2, 2)
    assert Island.guess(dot, coordinate) == :miss

    {:ok, new_coordinate} = Coordinate.new(4, 4)
    {:hit, dot} = Island.guess(dot, new_coordinate)

    assert dot == %Island{
             coordinates: MapSet.new([%Coordinate{col: 4, row: 4}]),
             hit_coordinates: MapSet.new([%Coordinate{col: 4, row: 4}])
           }

    assert Island.forested?(dot) == true
  end
end
