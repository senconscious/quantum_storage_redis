defmodule QuantumStorageRedis.MixProject do
  use Mix.Project

  @source_url "https://github.com/senconscious/quantum_storage_redis"

  def project do
    [
      app: :quantum_storage_redis,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      preferred_cli_env: [
        check: :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/project.plt"}
      ],
      name: "Quantum Storage Redis",
      source_url: @source_url
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
      check: ["format --check-formatted", "credo --strict", "dialyzer --format github", "test"]
    ]
  end

  defp description do
    "A redis storage adapter for quantum"
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
                CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
