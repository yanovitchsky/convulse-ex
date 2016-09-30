defmodule ConvulseSpec do
  use ESpec

  describe "Convulse" do
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

    it "caches response"
  end
end
