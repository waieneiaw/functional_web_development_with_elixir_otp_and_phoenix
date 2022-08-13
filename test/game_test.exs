defmodule IslandsEngineTest.Game do
  use ExUnit.Case
  use GenServer

  alias IslandsEngine.{Board, Game, Guesses, Rules}

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
end
