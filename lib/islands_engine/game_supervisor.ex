defmodule IslandsEngine.GameSupervisor do
  @moduledoc """
  `:simple_one_for_one`がdeprecatedなので`DynamicSupervisor`で実装している。
  """
  use DynamicSupervisor

  alias IslandsEngine.{Game, Player}

  @impl DynamicSupervisor
  @spec init(:ok) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_link(any) :: Supervisor.on_start()
  def start_link(_options),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @spec start_game(Player.name()) :: DynamicSupervisor.on_start_child()
  def start_game(name) do
    #  `DynamicSupervisor`の仕様が変わったのか、ネットで提示されている例では対処できず。
    # ↓の方法でようやく動作できた。
    #
    # 参考になったURLはこちら。
    # https://elixirforum.com/t/migrating-to-dynamicsupervisor-from-supervisor-elixir/28711/2
    spec = %{id: Game, start: {Game, :start_link, [name]}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @spec stop_game(Player.name()) :: :ok | {:error, :not_found}
  def stop_game(name) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  @spec pid_from_name(Player.name()) :: nil | pid
  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
