defmodule IslandsEngine.Coordinate do
  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct row: nil, col: nil

  @type t(row, col) :: %Coordinate{row: row, col: col}
  @type t :: %Coordinate{row: integer, col: integer}

  @board_range 1..10

  @spec new(integer, integer) ::
          {:error, :invalid_coordinate} | {:ok, IslandsEngine.Coordinate.t()}
  def new(row, col) when row in @board_range and col in @board_range,
    do: {:ok, %Coordinate{row: row, col: col}}

  def new(_row, _col),
    do: {:error, :invalid_coordinate}
end
