defmodule TopicSuper do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :topic,
        start: {Topic, :start_link, []}
      },
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
