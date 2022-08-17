defmodule RulesTest.Rules do
  use ExUnit.Case

  alias IslandsEngine.Rules

  test "checks `add_player`" do
    rules = Rules.new()
    assert rules.state == :initialized

    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set
  end

  test "is wrong action" do
    rules = Rules.new()
    :error = Rules.check(rules, :completely_wrong_action)
    assert rules.state == :initialized
  end

  test "sets islands" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}
    assert rules.state == :players_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set
  end

  test "checks state machines" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}
    assert rules.state == :players_set

    # player1
    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set
    assert Rules.check(rules, {:position_islands, :player1}) == :error

    # player2
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert rules.state == :player1_turn
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_set
    assert Rules.check(rules, {:position_islands, :player2}) == :error

    # other actions are forbidden
    assert Rules.check(rules, :add_player) == :error
    assert Rules.check(rules, {:position_islands, :player1}) == :error
    assert Rules.check(rules, {:position_islands, :player2}) == :error
    assert Rules.check(rules, {:set_islands, :player1}) == :error
  end

  test "guesses coordinates" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    assert Rules.check(rules, {:guess_coordinate, :player2}) == :error
  end

  test "checks win or no_win" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end

  test "all the events" do
    rules = Rules.new()
    assert rules.state == :initialized

    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set
    assert Rules.check(rules, {:position_islands, :player1}) == :error

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert rules.state == :player1_turn
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_set
    assert Rules.check(rules, {:guess_coordinate, :player2}) == :error

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert rules.state == :player2_turn
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_set
    assert Rules.check(rules, {:guess_coordinate, :player1}) == :error

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over

    assert Rules.check(rules, :add_player) == :error
  end
end
