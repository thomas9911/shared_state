{:ok, _} = Supervisor.start_link([SharedState.Supervisor], strategy: :one_for_one)

ExUnit.start()
