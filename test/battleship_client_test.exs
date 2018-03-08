defmodule BattleshipClientTest do
  use ExUnit.Case
  doctest BattleshipClient

  test "greets the world" do
    assert BattleshipClient.hello() == :world
  end
end
