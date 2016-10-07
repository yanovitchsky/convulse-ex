defmodule ConvulseSpec do
  use ESpec

  describe "Convulse" do
    # before do
    #   Convulse.Supervisor.start_link()
    # end

    it "queries service" do
      res = Convulse.discover(:sap_bridge)
      expect res |> to(have_size 1)

      expect List.first(res) |> to(have_key :service_name)
      expect List.first(res) |> to(have_key :address)
      expect List.first(res) |> to(have_key :port)
    end

    it "returns error with unknown service name" do
      res = Convulse.discover(:plop)
      expect res |> to(eq {:error, :unknown_service})
    end

    it "caches response" do
      res = Convulse.discover(:sap_bridge)
      service = res |> List.first |> Map.get(:service_name)
      expect service |> to(eq "sap_bridge")
      allow HTTPoison |> to(accept(:get, fn(args) -> passthrough([args]) end))
      res = Convulse.discover(:sap_bridge)
      expect HTTPoison |> to_not(accepted :get)
      service = res |> List.first |> Map.get(:service_name)
      expect service |> to(eq "sap_bridge")
    end

    it "does not cache if first call is error" do
      Convulse.discover(:plop)
      expect Cachex.get(:convulse, "plop") |> to(eq {:missing, nil})
    end

    it "cleans cache after defined ttl" do
      Convulse.discover(:sap_bridge)
      {:ok, res} = Cachex.get(:convulse, "sap_bridge")
      expect res |> to_not(eq nil)
      :timer.sleep(4000)
      expect Cachex.get(:convulse, "sap_bridge") |> to(eq {:missing, nil})
    end
  end
end
