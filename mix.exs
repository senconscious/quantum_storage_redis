defmodule QuantumStorageRedis.MixProject do
  use Mix.Project

  def project do
    [
      app: :quantum_storage_redis,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
