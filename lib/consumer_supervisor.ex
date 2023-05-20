defmodule ConsumerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Task.Supervisor, name: ConsumerServer},
      {Consumer, 6000}
    ]

    IO.inspect("Consumer Supervisor started")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
