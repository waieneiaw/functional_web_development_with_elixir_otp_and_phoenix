defmodule IslandsEngineTest.Coordinate do
  use ExUnit.Case

  alias IslandsEngine.Coordinate

  test "verification of coordinate range" do
    assert match?({:ok, _}, Coordinate.new(1, 1))
    assert match?({:ok, _}, Coordinate.new(10, 10))

    assert match?({:error, _}, Coordinate.new(0, 1))
    assert match?({:error, _}, Coordinate.new(1, 0))
    assert match?({:error, _}, Coordinate.new(1, 11))
    assert match?({:error, _}, Coordinate.new(11, 1))
  end
end
