defmodule SharedState.StateTest do
  use ExUnit.Case

  alias SharedState.State

  describe "empty" do
    setup do
      State.init()
    end

    test "state returns empty state" do
      assert %{} == State.state()
    end

    test "cast returns ok" do
      assert :ok == State.cast(& &1)
    end

    test "get returns empty state" do
      assert %{} == State.get(& &1)
    end

    test "get update returns empty state" do
      assert %{} == State.get_and_update(&{&1, &1})
    end

    test "update returns ok" do
      assert :ok == State.update(&Map.put(&1, :ok, 1))
    end
  end

  describe "map" do
    setup do
      State.init(%{test: 1})
    end

    test "state returns empty state" do
      assert %{test: 1} == State.state()
    end

    test "cast returns ok" do
      assert :ok == State.cast(& &1)
    end

    test "get returns empty state" do
      assert 1 == State.get(&Map.get(&1, :test))
    end

    test "get update returns empty state" do
      assert %{test: 1} == State.get_and_update(&{&1, Map.put(&1, :ok, 2)})
      assert %{test: 1, ok: 2} == State.state()
    end

    test "update returns ok" do
      assert :ok == State.update(&Map.put(&1, :ok, 1))
      assert %{test: 1, ok: 1} == State.state()
    end
  end
end
