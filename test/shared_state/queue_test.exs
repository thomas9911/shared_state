defmodule SharedState.QueueTest do
  use ExUnit.Case

  alias SharedState.{State, Queue, Error}

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

  defp queue_limit_sum(amount) do
    # handwavy limit based on sum of integers formula:
    # (highest_number+lowest_number)*amount_of_numbers/2
    :math.pow(amount * length(Queue.all_workers()), 2)
  end

  describe "empty" do
    setup do
      Queue.clear_all()
      State.init()
    end

    test "actions get pushed" do
      Enum.each(0..9, fn _ -> Queue.push(&nothing/1) end)

      queues = Queue.all_states()
      assert is_map(queues)

      funcs = Enum.flat_map(queues, fn {_, v} -> v end)

      assert 10 == length(funcs)
    end

    test "update actions" do
      Enum.each(0..9, fn _ -> Queue.push(&update_map/1) end)
      Queue.flush_all()

      quick_sleep()
      assert %{test: 10} == State.state()
      assert 10 == State.get(& &1.test)
    end

    test "update actions in chunks" do
      Enum.each(0..999, fn _ -> Queue.push(&update_map/1) end)
      Queue.flush_all_amount(5)

      quick_sleep()
      assert %{test: 5 * length(Queue.all_workers())} == State.state()
    end

    test "update actions in chunks goes in order, fifo default" do
      Enum.each(0..999, fn i -> Queue.push(&update_map_with_index(&1, i)) end)
      Queue.flush_all_amount(5)

      quick_sleep()
      counter = State.get(& &1.test)

      assert counter < queue_limit_sum(5)
    end

    test "update actions in chunks goes in order, lifo" do
      Enum.each(0..999, fn i -> Queue.push(&update_map_with_index(&1, i)) end)
      Queue.flush_all_amount(5, :lifo)

      quick_sleep()
      counter = State.get(& &1.test)

      assert counter > queue_limit_sum(5)
    end

    test "kill all restarts workers" do
      assert :ok == Queue.kill_all() |> Error.format()
      assert :ok == Queue.push(fn state -> Map.put(state, :a, 1) end)
    end
  end
end
