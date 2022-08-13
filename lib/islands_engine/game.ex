defmodule IslandsEngine.Game do
  use GenServer

  alias IslandsEngine.{Board, Guesses, Rules}

  @typep process_name :: String.t()

  @typep player_state :: %{
           name: process_name() | nil,
           board: Board.t(),
           guesses: Guesses.t()
         }

  @spec init(process_name()) ::
          {:ok, %{player1: player_state(), player2: player_state(), rules: Rules.t()}}
  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  @spec start_link(process_name()) :: GenServer.on_start()
  def start_link(name) when is_binary(name),
    do: GenServer.start_link(__MODULE__, name, [])
end
