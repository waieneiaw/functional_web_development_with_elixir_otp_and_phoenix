defmodule IslandsEngineTest.Game do
  use ExUnit.Case
  use GenServer

  alias IslandsEngine.{Board, Coordinate, Game, Guesses, Island, Rules}

  test "start GenServer" do
    {:ok, game} = Game.start_link("Frank")

    state_data = :sys.get_state(game)

    assert state_data.player1.name == "Frank"
    assert state_data.player1.board == Board.new()
    assert state_data.player1.guesses == Guesses.new()

    assert state_data.player2.name == nil
    assert state_data.player2.board == Board.new()
    assert state_data.player2.guesses == Guesses.new()

    # `%Rules{}`は初期値を持っているので明示的にセットせずとも↓の状態になる。
    # ```elixir
    # assert state_data.rules == %Rules{
    #      state: :initialized,
    #      player1: :islands_not_set,
    #      player2: :islands_not_set
    #    }
    # ```
    assert state_data.rules == %Rules{}
  end

  test "add a second player" do
    {:ok, game} = Game.start_link("Frank")

    Game.add_player(game, "Dweezil")
    state_data = :sys.get_state(game)

    assert state_data.player2.name == "Dweezil"
  end

  test ":players_set" do
    {:ok, game} = Game.start_link("Fred")

    Game.add_player(game, "Wilma")
    state_data = :sys.get_state(game)

    assert state_data.rules.state == :players_set

    Game.position_island(game, :player1, :square, 1, 1)
    state_data = :sys.get_state(game)

    assert state_data.player1.board == %{
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

    assert Game.position_island(game, :player1, :dot, 12, 1) ==
             {:error, :invalid_coordinate}

    assert Game.position_island(game, :player1, :l_shape, 10, 10) ==
             {:error, :invalid_coordinate}

    state_data =
      :sys.replace_state(game, fn state_data ->
        %Game{state_data | rules: %Rules{state: :player1_turn}}
      end)

    assert state_data.rules.state == :player1_turn

    assert Game.position_island(game, :player1, :dot, 5, 5) == :error
  end

  test "set_islands" do
    {:ok, game} = Game.start_link("Dino")

    Game.add_player(game, "Pebbles")

    # まだ何も配置していないのでエラーが返ってくる
    set_islands_error = {:error, :not_all_islands_positioned}

    assert Game.set_islands(game, :player1) == set_islands_error

    Game.position_island(game, :player1, :atoll, 1, 1)
    assert Game.set_islands(game, :player1) == set_islands_error

    Game.position_island(game, :player1, :dot, 1, 4)
    assert Game.set_islands(game, :player1) == set_islands_error

    Game.position_island(game, :player1, :l_shape, 1, 5)
    assert Game.set_islands(game, :player1) == set_islands_error

    Game.position_island(game, :player1, :s_shape, 5, 1)
    assert Game.set_islands(game, :player1) == set_islands_error

    Game.position_island(game, :player1, :square, 5, 5)

    # すべて配置したので成功する
    result = Game.set_islands(game, :player1)
    assert match?({:ok, _}, result)

    state_data = :sys.get_state(game)
    assert state_data.rules.player1 == :islands_set
    assert state_data.rules.state == :players_set
  end

  test "guesses islands" do
    {:ok, game} = Game.start_link("Miles")

    Game.add_player(game, "Trane")

    # まだ推測できない
    assert Game.guess_coordinate(game, :player1, 1, 1) == :error

    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)

    # `:player1_turn`を手動で設定する
    state_data =
      :sys.replace_state(game, fn data ->
        %Game{data | rules: %Rules{state: :player1_turn}}
      end)

    assert state_data.rules.state == :player1_turn

    # 失敗
    assert Game.guess_coordinate(game, :player1, 5, 5) == {:miss, :none, :no_win}
    # 連続で実行するとエラーが発生する
    assert Game.guess_coordinate(game, :player1, 3, 5) == :error

    # player2がplayer1の`dot`を当てたので勝利する
    assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :win}
  end

  test "Naming GenServer Processes" do
    via = Game.via_tuple("Lena")
    GenServer.start_link(Game, "Lena", name: via)
    result = GenServer.start_link(Game, "Lena", name: via)
    assert match?({:error, _}, result)
  end
end
