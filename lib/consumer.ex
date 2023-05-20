defmodule Consumer do
  use Task
  require Logger

  def start_link(port) do
    Task.start_link(__MODULE__, :run, [port])
  end

  def run(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Consumer Server Started.")
    loop(socket)
  end

  def loop(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        Logger.info("Consumer accepted")
        {:ok, pid} = Task.Supervisor.start_child(ConsumerServer, fn() -> ConsumerHandler.serve(client) end)
        :ok = :gen_tcp.controlling_process(client, pid)
        loop(socket)
      {:error, reason} ->
        Logger.info("Consumer error: #{reason}")
      end
  end
end
