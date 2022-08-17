defmodule IslandsEngine.Coordinate do
  @enforce_keys [:row, :col]
  defstruct @enforce_keys

  @type t(row, col) :: %__MODULE__{row: row, col: col}
  @type t :: %__MODULE__{row: integer, col: integer}

  @board_range 1..10

  @type coordinates :: MapSet.t(__MODULE__.t())

  @type row :: integer
  @type col :: integer

  @type offset :: {row(), col()}

  @spec new(row(), col()) ::
          {:error, :invalid_coordinate} | {:ok, __MODULE__.t()}
  def new(row, col) when row in @board_range and col in @board_range,
    do: {:ok, %__MODULE__{row: row, col: col}}

  def new(_row, _col),
    do: {:error, :invalid_coordinate}
end
