defmodule IslandsEngine.Guesses do
  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct @enforce_keys

  @type t(hits, misses) :: %__MODULE__{hits: hits, misses: misses}
  @type t :: %__MODULE__{
          hits: Coordinate.coordinates(),
          misses: Coordinate.coordinates()
        }

  @type hit_or_miss :: :hit | :miss

  @spec new :: __MODULE__.t()
  def new(), do: %__MODULE__{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(__MODULE__.t(), hit_or_miss(), Coordinate.t()) :: __MODULE__.t()
  def add(%__MODULE__{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%__MODULE__{} = guesses, :miss, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
