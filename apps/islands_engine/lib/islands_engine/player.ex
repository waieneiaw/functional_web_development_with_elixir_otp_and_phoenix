defmodule IslandsEngine.Player do
  @moduledoc """
  このモジュールを作らないと`Game.update_board/3`で型が合わずにエラーが発生するため、急遽作成した。
  """

  alias IslandsEngine.{Board, Guesses}

  @enforce_keys [:name, :board, :guesses]
  defstruct @enforce_keys

  @typedoc """
  プレイヤーの名前。書籍では`player_key`だったり`player`として引数に定義されている。
  """
  @type name :: String.t()

  @typedoc """
  もとは`Rules`モジュールに持たせていたが、
  `Player`モジュールが登場した以上はこちらで持つべきと判断し、`Rules`の`player`を移行した。
  `role`という名前が適切かはわからないが、「役割」ではあるので`role`と命名しておく。
  """
  @type role :: :player1 | :player2

  @roles [:player1, :player2]

  @doc """
  `:player1`もしくは`:player2`を保証するガード。

  書籍では`Game`モジュールに`@players`として定数で持っていたが、
  `Player`モジュールを勝手に作ってしまったのでこちらで定義する。
  """
  defguard is_role(role) when role in @roles

  @type t :: %__MODULE__{
          name: name() | nil,
          board: Board.t(),
          guesses: Guesses.t()
        }

  @spec new(name()) :: IslandsEngine.Player.t()
  def new(name),
    do: %__MODULE__{name: name, board: Board.new(), guesses: Guesses.new()}

  @spec new :: IslandsEngine.Player.t()
  def new(),
    do: %__MODULE__{name: nil, board: Board.new(), guesses: Guesses.new()}
end
