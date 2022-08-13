defmodule IslandsEngineTest.Game do
  use ExUnit.Case
  use GenServer

  alias IslandsEngine.Game

  test "handle_info" do
    {:ok, game} = GenServer.start_link(Game, %{}, [])
    assert send(game, :first) == :first
  end

  test "handle_call" do
    {:ok, game} = GenServer.start_link(Game, %{test: "test value"}, [])
    result = GenServer.call(game, :demo_call)
    assert result == %{test: "test value"}
  end

  test "demo_call" do
    {:ok, game} = GenServer.start_link(Game, %{test: "test value"}, [])
    result = Game.demo_call(game)
    assert result == %{test: "test value"}
  end

  test "handle_cast" do
    {:ok, game} = GenServer.start_link(Game, %{test: "test value"}, [])
    assert Game.demo_call(game) == %{test: "test value"}
    # 値を更新する
    GenServer.cast(game, {:demo_cast, "another value"})
    assert Game.demo_call(game) == %{test: "another value"}
  end

  test "demo_cast" do
    {:ok, game} = GenServer.start_link(Game, %{test: "test value"}, [])
    assert Game.demo_call(game) == %{test: "test value"}
    # 値を更新する
    Game.demo_cast(game, "another value")
    assert Game.demo_call(game) == %{test: "another value"}
  end
end
