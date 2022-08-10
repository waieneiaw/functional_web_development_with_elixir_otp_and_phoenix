defmodule IslandsEngine.Guesses do
  alias __MODULE__

  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct hits: nil, misses: nil

  @type t(hits, misses) :: %Guesses{hits: hits, misses: misses}
  @type t :: %Guesses{hits: MapSet.t(Coordinate), misses: MapSet.t(Coordinate)}

  @spec new :: IslandsEngine.Guesses.t()
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}
end
