defmodule IslandsEngine.Guesses do
  alias __MODULE__
  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct hits: nil, misses: nil

  @type t(hits, misses) :: %__MODULE__{hits: hits, misses: misses}
  @type t :: %__MODULE__{
          hits: Coordinate.coordinates(),
          misses: Coordinate.coordinates()
        }

  @spec new :: Guesses.t()
  def new(), do: %__MODULE__{hits: MapSet.new(), misses: MapSet.new()}
end
