defmodule Lab3 do
  use Application

  def start(_type, _args) do
    MainSuper.start_link()
  end
end
