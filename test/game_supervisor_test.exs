defmodule IslandsEngineTest.GameSupervisor do
  use ExUnit.Case

  alias IslandsEngine.{Game, GameSupervisor}

  @restarting_time_ms 5000

  setup do
    :ets.delete_all_objects(:game_state)
    :ok
  end

  test "it starts and stops a process" do
    {:ok, game} = GameSupervisor.start_game("Cassatt")

    via = Game.via_tuple("Cassatt")
    assert via == {:via, Registry, {Registry.Game, "Cassatt"}}

    assert Supervisor.count_children(GameSupervisor) == %{
             active: 1,
             specs: 1,
             supervisors: 0,
             workers: 1
           }

    data = Supervisor.which_children(GameSupervisor)
    assert data == [{:undefined, game, :worker, [IslandsEngine.Game]}]

    GameSupervisor.stop_game("Cassatt")

    refute Process.alive?(game)
    refute GenServer.whereis(via)
  end

  @tag :skip
  test "a process stops after #{Game.get_timeout_ms()} ms" do
    {:ok, game} = GameSupervisor.start_game("Cassatt")

    assert Process.alive?(game)

    :timer.sleep(Game.get_timeout_ms())

    refute Process.alive?(game)
  end

  test "a process restarts" do
    {:ok, game} = GameSupervisor.start_game("Hopper")

    via = Game.via_tuple("Hopper")

    assert GenServer.whereis(via) == game

    assert Game.add_player(via, "Hockney") == :ok

    state_data = :sys.get_state(via)

    assert state_data.player1.name == "Hopper"
    assert state_data.player2.name == "Hockney"

    assert Process.exit(game, :kaboom) == true
    refute GenServer.whereis(via) == game

    # プロセスが終了した後、再起動するまで待たないといけない
    :timer.exit_after(@restarting_time_ms, "wait for restarting")
    wait_until_restarted(via)

    # ↓書籍ではプロセスが再起動した時に`player2`が`nil`になることを提示しているが、
    # ETSを使ったコードに変更されたことで`player2`も無事に復活してしまうため、コメントアウトする。
    # state_data = :sys.get_state(via)
    # assert state_data.player1.name == "Hopper"
    # assert state_data.player2.name == nil

    # プロセスを止めないと他のテストでも影響が出てしまう
    GameSupervisor.stop_game("Hopper")
  end

  test "" do
    {:ok, game} = GameSupervisor.start_game("Morandi")

    [{"Morandi", value}] = :ets.lookup(:game_state, "Morandi")
    assert value.player1.name == "Morandi"
    assert value.player2.name == nil

    assert Game.add_player(game, "Rothko") == :ok
    [{"Morandi", value}] = :ets.lookup(:game_state, "Morandi")
    assert value.player1.name == "Morandi"
    assert value.player2.name == "Rothko"

    via = Game.via_tuple("Morandi")
    assert Process.exit(game, :kaboom) == true

    :timer.exit_after(@restarting_time_ms, "wait for restarting")
    wait_until_restarted(via)

    state_data = :sys.get_state(via)
    assert state_data.player1.name == "Morandi"
    assert state_data.player2.name == "Rothko"

    # GameSupervisor.stop_game("Morandi")
  end

  # プロセスが再起動するまでループする
  @spec wait_until_restarted(tuple()) :: nil
  defp wait_until_restarted(via) do
    unless GenServer.whereis(via) do
      wait_until_restarted(via)
    end
  end
end
