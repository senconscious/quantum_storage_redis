defmodule QuantumStorageRedis.MixProject do
  use Mix.Project

  def project do
    [
      app: :quantum_storage_redis,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        check: :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:quantum, ">= 2.2.1"},
      {:timex, "~> 3.0"},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      check: ["format --check-formatted", "credo --strict", "dialyzer", "test"]
    ]
  end
end
