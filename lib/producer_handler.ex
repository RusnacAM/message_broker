defmodule ProducerHandler do
  require Logger

  def serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        publish(data)
        serve(socket)
      {:error, :closed} ->
        Logger.info("Producer closed")
      {:error, reason} ->
        Logger.info("Producer error: #{reason}")
    end
  end

  def publish(data) do
    Broker.publish(data)
  end
end
