defmodule IslandsEngineTest do
  use ExUnit.Case
  doctest IslandsEngine

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end
end

defmodule IslandsEngineTest.Coordinate do
  use ExUnit.Case

  alias IslandsEngine.Coordinate

  test "overflow" do
    assert match?({:ok, _}, Coordinate.new(1, 1))
    assert match?({:ok, _}, Coordinate.new(10, 10))
    assert match?({:error, _}, Coordinate.new(0, 1))
    assert match?({:error, _}, Coordinate.new(1, 0))
    assert match?({:error, _}, Coordinate.new(1, 11))
    assert match?({:error, _}, Coordinate.new(11, 1))
  end
end

defmodule IslandsEngineTest.Guesses do
  use ExUnit.Case

  alias IslandsEngine.Guesses
  alias IslandsEngine.Coordinate

  test "equal value" do
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
end
