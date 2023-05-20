defmodule Topic do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 6001, [:binary, packet: :line, active: false, reuseaddr: true])
    send_timeout()
    {:ok, socket}
  end

  def send_timeout() do
    Process.send_after(self(), :send, 500)
  end

  def handle_info(:send, socket) do
    message = get_message()
    payload = %{topic: message["type"],
                message: message["activity"]}
    packet = "#{payload |> Poison.Encoder.encode(%{strict_keys: true})}\n"
    :ok = :gen_tcp.send(socket, packet)
    {:noreply, socket}
    # IO.inspect(message)
  end

  def get_message() do
    response = HTTPoison.get!("https://www.boredapi.com/api/activity")
    text = response.body()
    {response, data} = Jason.decode(text)
    send_timeout()
    data
  end
end
