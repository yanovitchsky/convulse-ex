defmodule Convulse.Mixfile do
  use Mix.Project

  def project do
    [app: :convulse,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [espec: :test],
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     package: package,
     docs: [
       extras: ["README.md"],
       main: "readme",
     ]
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :httpoison, :cachex],
      mod: { Convulse, [] }
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"},
      {:cachex, "~> 1.2"},
      {:espec, "~> 0.8.18", only: :test}
    ]
  end

  defp package do
    %{ licenses: ["MIT"] }
  end

  defp elixirc_paths(:test), do: ["lib", "spec/support"]
  defp elixirc_paths(_), do: ["lib"]
end
