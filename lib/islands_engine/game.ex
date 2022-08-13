defmodule IslandsEngine.Game do
  use GenServer

  # `init`がないとテスト実行できないため、とりあえず実装だけしておく
  def init(init_arg) do
    {:ok, init_arg}
  end

  # これで`:first`を返すらしい。
  def handle_info(:first, state) do
    IO.puts("This message has been handled by handle_info/2, maching on :first")
    {:noreply, state}
  end

  def handle_call(:demo_call, _from, state) do
    {:reply, state, state}
  end

  @spec demo_call(GenServer.on_start()) :: map
  def demo_call(game) do
    GenServer.call(game, :demo_call)
  end

  def handle_cast({:demo_cast, new_value}, state) do
    {:noreply, Map.put(state, :test, new_value)}
  end

  @spec demo_cast(GenServer.on_start(), map) :: :ok
  def demo_cast(pid, new_value) do
    GenServer.cast(pid, {:demo_cast, new_value})
  end
end
