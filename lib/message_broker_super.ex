defmodule MessageBrokerSuper do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :broker,
        start: {Broker, :start_link, []}
      }
    ]

    IO.inspect("Message Broker Supervisor started")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
