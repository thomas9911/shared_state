defmodule SharedState.StateQueueTest do
  use ExUnit.Case

  alias SharedState.{State, StateQueue}

  defp nothing(state), do: state

  defp update_map(state) do
    state
    |> Map.put_new(:test, 0)
    |> Map.update!(:test, &(&1 + 1))
  end

  defp update_map_with_index(state, i) do
    state
    |> Map.put_new(:test, 0)
    |> Map.update!(:test, &(&1 + i))
  end

  defp quick_sleep() do
    # wait a bit before claiming the state
    Process.sleep(5)
  end

  describe "empty" do
    setup do
      StateQueue.clear_all()
      State.init()
    end

    test "actions get pushed" do
      Enum.each(0..9, fn _ -> StateQueue.push(&nothing/1) end)

      queues = StateQueue.all_states()
      assert is_map(queues)

      funcs = Enum.flat_map(queues, fn {_, v} -> v end)

      assert 10 == length(funcs)
    end

    test "update actions" do
      Enum.each(0..9, fn _ -> StateQueue.push(&update_map/1) end)
      StateQueue.flush_all()

      quick_sleep()
      assert %{test: 10} == State.state()
    end

    test "update actions in chunks" do
      Enum.each(0..99, fn _ -> StateQueue.push(&update_map/1) end)
      StateQueue.flush_all_amount(5)

      quick_sleep()
      assert %{test: 15} == State.state()
    end

    test "update actions in chunks goes in order, fifo default" do
      Enum.each(0..99, fn i -> StateQueue.push(&update_map_with_index(&1, i)) end)
      StateQueue.flush_all_amount(5)

      quick_sleep()
      assert %{test: counter} = State.state()

      # more than 1000 you would get if the last elements gets evaluated first
      assert counter < 1000
    end

    test "update actions in chunks goes in order, lifo" do
      Enum.each(0..99, fn i -> StateQueue.push(&update_map_with_index(&1, i)) end)
      StateQueue.flush_all_amount(5, :lifo)

      quick_sleep()
      assert %{test: counter} = State.state()

      # less than 250 you would get if the first elements gets evaluated first
      assert counter > 250
    end
  end
end
