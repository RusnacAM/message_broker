defmodule MainSuper do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :consumersuper,
        start: {ConsumerSupervisor, :start_link, []}
      },
      %{
        id: :producersuper,
        start: {ProducerSupervisor, :start_link, []}
      },
      %{
        id: :topicsuper,
        start: {TopicSuper, :start_link, []}
      },
      %{
        id: :brokersuper,
        start: {MessageBrokerSuper, :start_link, []}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
