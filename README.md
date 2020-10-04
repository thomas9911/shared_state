# SharedState

To get started add `SharedState.Supervisor` to your supervisor tree.

```elixir
  children = [
    SharedState.Supervisor
  ]
```

The default of processes for the queue is 3. You can set this by passing :queue_processes in the supervisor tree.

```elixir
  children = [
    {SharedState.Supervisor, queue_processes: 5}
  ]
```

or adding it in you config under:

```elixir
  config :shared_state, queue_processes: 8
```

It is ofcourse possible to create a schedule that flushes the queue after a period of time.
take a look at: <https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages>
And use the function `SharedState.Queue.flush_all/0` to flush all the updates to the main state.

