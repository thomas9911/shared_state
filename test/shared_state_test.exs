defmodule SharedStateTest do
  use ExUnit.Case
  doctest SharedState

  test "greets the world" do
    assert SharedState.hello() == :world
  end
end
