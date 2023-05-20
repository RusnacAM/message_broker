defmodule ConsumerHandler do
  require Logger

  def serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        command = String.trim(data)
        |> String.split(" ")
        |> get_command(socket)
        serve(socket)
      {:error, :closed} ->
        Logger.info("Consumer closed")
      {:error, reason} ->
        Logger.info("Consumer error: #{reason}")
    end
  end

  defp get_command(command, socket) do
    user_command = Enum.at(command, 0)
    arg = Enum.at(command, 1)
    case [user_command, arg] do
      ["sub", arg] ->
        response = Broker.subscribe(arg, socket)
        case response do
          :ok ->
            :gen_tcp.send(socket, "Subscribed to #{arg} \r\n")
          :error ->
            :gen_tcp.send(socket, "You are already subscribed to \"#{arg}\" or doesn't exist \r\n")
        end
      ["get", _] ->
        response = Broker.get_topics()
        :gen_tcp.send(socket, "Topics: #{fn() -> Enum.join(response, ", ") end.()} \r\n")
    end
  end

end

# telnet 127.0.0.1 6000
