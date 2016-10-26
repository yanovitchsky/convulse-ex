defmodule Convulse.Server do
  use GenServer

  @base_url "consul.service.consul:8500/v1/catalog/service/"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def discover(service_name) do
    GenServer.call(__MODULE__, {:discover, service_name})
  end

  # callbacks
  def handle_call({:discover, service_name}, _from, state) do
    # {:reply, "hello world", service_name}
    services = case get_from_cache(service_name) do
      # not in cache
      {:ok, nil} ->
        fetch_from_consul(service_name)
      # expired from cache
      {:missing, _} ->
        fetch_from_consul(service_name)
      # in cache
      {:ok, value} -> {:ok, value}
    end

    {:reply, services, service_name}
  end

  defp get_from_cache(service_name) do
    Cachex.get(:convulse, Atom.to_string(service_name))
  end

  defp cache_response(service_name, value) do
    cache_ttl = Application.get_env(:convulse, :ttl) || 30
    Cachex.set(:convulse, Atom.to_string(service_name), value, [ttl: :timer.seconds(cache_ttl)])
  end

  defp fetch_from_consul(service_name) do
    url = @base_url <> Atom.to_string(service_name)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        result = body |> Poison.decode!
        if length(result) > 0 do
          services = result |> Enum.map(fn(res) ->
                %{
                  service_name: Map.get(res, "ServiceName"),
                  address: Map.get(res, "ServiceAddress"),
                  port: Map.get(res, "ServicePort"),
                }
              end)
          cache_response(service_name, services)
          {:ok, services}
        else
          {:error, :unknown_service}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
