defmodule SharedStateTest do
  use ExUnit.Case
  doctest SharedState

  alias SharedState.{Queue, State}

  defp quick_sleep() do
    # wait a bit before claiming the state
    Process.sleep(5)
  end

  describe "works" do
    setup do
      Queue.clear_all()
      State.init()
    end

    test "update" do
      assert :ok == SharedState.update(fn state -> Map.put(state, :a, 1) end)

      quick_sleep()

      assert %{a: 1} == State.state()
    end

    test "update lazy" do
      assert :ok == SharedState.update_lazy(fn state -> Map.put(state, :a, 1) end)

      quick_sleep()

      assert %{} == State.state()
    end

    test "get" do
      assert :ok == SharedState.update(fn state -> Map.put(state, :a, 1) end)

      assert 1 == SharedState.get(& &1.a)
    end

    test "get, flushes queues" do
      assert :ok == SharedState.update(fn state -> Map.put(state, :a, 0) end)

      Enum.each(0..100, fn i ->
        assert :ok == SharedState.update_lazy(fn state -> Map.update!(state, :a, &(&1 + i)) end)
      end)

      assert 101 == Queue.all_states() |> Enum.flat_map(&elem(&1, 1)) |> Enum.count()

      assert Enum.sum(0..100) == SharedState.get(& &1.a)
    end
  end

  describe "not works" do
    setup do
      Queue.clear_all()
      State.init()
    end
  end
end
