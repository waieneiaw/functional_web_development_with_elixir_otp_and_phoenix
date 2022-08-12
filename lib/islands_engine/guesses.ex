defmodule IslandsEngine.Guesses do
  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct hits: nil, misses: nil

  @type t(hits, misses) :: %__MODULE__{hits: hits, misses: misses}
  @type t :: %__MODULE__{
          hits: Coordinate.coordinates(),
          misses: Coordinate.coordinates()
        }

  @spec new :: __MODULE__.t()
  def new(), do: %__MODULE__{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(__MODULE__.t(), :hit | :miss, Coordinate.t()) :: __MODULE__.t()
  def add(%__MODULE__{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%__MODULE__{} = guesses, :miss, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
