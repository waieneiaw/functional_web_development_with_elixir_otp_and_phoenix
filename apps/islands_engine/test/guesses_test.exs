defmodule IslandsEngineTest.Guesses do
  use ExUnit.Case

  alias IslandsEngine.Guesses
  alias IslandsEngine.Coordinate

  test "check guesses" do
    guesses = Guesses.new()

    {:ok, coordinate1} = Coordinate.new(1, 1)
    {:ok, coordinate2} = Coordinate.new(2, 2)

    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))

    assert guesses == %Guesses{
             hits: MapSet.new([%Coordinate{col: 1, row: 1}]),
             misses: MapSet.new([])
           }

    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))

    assert guesses == %Guesses{
             hits:
               MapSet.new([
                 %Coordinate{col: 1, row: 1},
                 %Coordinate{col: 2, row: 2}
               ]),
             misses: MapSet.new([])
           }

    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))

    assert guesses == %Guesses{
             hits:
               MapSet.new([
                 %Coordinate{col: 1, row: 1},
                 %Coordinate{col: 2, row: 2}
               ]),
             misses: MapSet.new([])
           }
  end

  test "add" do
    guesses = Guesses.new()

    {:ok, coordinate1} = Coordinate.new(8, 3)
    guesses = Guesses.add(guesses, :hit, coordinate1)

    assert guesses == %Guesses{
             hits:
               MapSet.new([
                 %Coordinate{col: 3, row: 8}
               ]),
             misses: MapSet.new()
           }

    {:ok, coordinate2} = Coordinate.new(9, 7)
    guesses = Guesses.add(guesses, :hit, coordinate2)

    assert guesses == %Guesses{
             hits:
               MapSet.new([
                 %Coordinate{col: 3, row: 8},
                 %Coordinate{col: 7, row: 9}
               ]),
             misses: MapSet.new()
           }

    {:ok, coordinate3} = Coordinate.new(1, 2)
    guesses = Guesses.add(guesses, :miss, coordinate3)

    assert guesses == %Guesses{
             hits:
               MapSet.new([
                 %Coordinate{col: 3, row: 8},
                 %Coordinate{col: 7, row: 9}
               ]),
             misses:
               MapSet.new([
                 %Coordinate{col: 2, row: 1}
               ])
           }
  end
end
