defmodule Convulse do

  use Application

  def start(_type, _args) do
    Convulse.Supervisor.start_link
  end

  def discover(service_name) do
    Convulse.Server.discover(service_name)
  end
end
