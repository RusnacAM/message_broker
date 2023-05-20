defmodule ProducerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Task.Supervisor, name: ProducerServer},
      {Producer, 6001}
    ]

    IO.inspect("Producer Supervisor started")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
