defmodule Broker do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def subscribe(topic, socket) do
    GenServer.call(__MODULE__, {:subscribe, topic, socket})
  end

  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end

  def get_topics() do
    GenServer.call(__MODULE__, :get_topics)
  end

  def handle_call(:get_topics, _from, state) do
    topics = Map.keys(state)
    {:reply, topics, state}
  end

  def handle_call({:subscribe, topic, socket}, _from, state) do
    keys = Map.keys(state)
    if (Enum.member?(keys, topic)) do
      case Map.get(state, topic) do
        nil ->
          new_state = Map.put(state, topic, [socket])
          IO.inspect(new_state)
          {:reply, :ok, new_state}
        subscribers ->
          if (Enum.member?(subscribers, socket)) do
            {:reply, :error, state}
          else
            new_state = Map.put(state, topic, [socket | subscribers])
            IO.inspect(new_state)
            {:reply, :ok, new_state}
          end
      end
    else
      {:reply, :error, state}
    end
  end

  def handle_cast({:publish, message}, state) do
    decoded = Poison.decode!(message)
    topic = Map.get(decoded, "topic")
    mess= Map.get(decoded, "message") <> "\r\n"

    subscribers = Map.get(state, topic, [])

    if (Map.has_key?(state, topic)) do
      Enum.each(subscribers, fn socket ->
      :gen_tcp.send(socket, mess)
      end)
      {:noreply, state}
    else
      new_state = Map.put(state, topic, [])
      {:noreply, new_state}
    end
  end
end
