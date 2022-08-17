defmodule IslandsEngineTest.Board do
  use ExUnit.Case

  alias IslandsEngine.{Board, Coordinate, Island}

  test "Putting the Pieces Together" do
    board = Board.new()

    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    board = Board.position_island(board, :square, square)

    assert board == %{
             square: %Island{
               coordinates:
                 MapSet.new([
                   %Coordinate{col: 1, row: 1},
                   %Coordinate{col: 1, row: 2},
                   %Coordinate{col: 2, row: 1},
                   %Coordinate{col: 2, row: 2}
                 ]),
               hit_coordinates: MapSet.new()
             }
           }

    # ---

    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    # すでに`square`が存在するので配置できない
    assert Board.position_island(board, :dot, dot) == {:error, :overlapping_island}

    # ---

    {:ok, dot_coordinate} = Coordinate.new(3, 3)
    {:ok, dot} = Island.new(:dot, dot_coordinate)
    board = Board.position_island(board, :dot, dot)

    # `square`以外の位置なので配置できる
    assert board == %{
             dot: %Island{
               coordinates: MapSet.new([%Coordinate{col: 3, row: 3}]),
               hit_coordinates: MapSet.new()
             },
             square: %Island{
               coordinates:
                 MapSet.new([
                   %Coordinate{col: 1, row: 1},
                   %Coordinate{col: 1, row: 2},
                   %Coordinate{col: 2, row: 1},
                   %Coordinate{col: 2, row: 2}
                 ]),
               hit_coordinates: MapSet.new()
             }
           }

    {:ok, guess_coordinate} = Coordinate.new(10, 10)

    # どこにも配置されていない座標なので、どこも`hit`せず
    assert Board.guess(board, guess_coordinate) == {:miss, :none, :no_win, board}

    # ---

    {:ok, hit_coordinate} = Coordinate.new(1, 1)

    expected_board = %{
      board
      | square: %{square | hit_coordinates: MapSet.new([hit_coordinate])}
    }

    # `hit`した
    assert Board.guess(board, hit_coordinate) == {:hit, :none, :no_win, expected_board}

    # ---

    # `square`をすべて`hit`した状態に変更する
    square = %{square | hit_coordinates: square.coordinates}
    board = Board.position_island(board, :square, square)

    {:ok, win_coordinate} = Coordinate.new(3, 3)

    expected_board = %{
      board
      | dot: %{dot | hit_coordinates: MapSet.new([win_coordinate])}
    }

    # すべて`hit`し、勝利した
    assert Board.guess(board, win_coordinate) == {:hit, :dot, :win, expected_board}
  end
end
