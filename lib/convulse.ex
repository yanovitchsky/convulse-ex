defmodule Convulse do

  @base_url "consul.service.consul:8500/v1/catalog/service/"

  def discover(service_name) do
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
