# Quantum Storage Redis

Quantum storage adapter for redis. This is basically a copy of [persistent ets implementation](https://github.com/quantum-elixir/quantum-storage-persistent-ets)

Uses [Redix](https://github.com/whatyouhide/redix) under the hood to communicate with redis.

## Installation

1. The package can be installed by adding `quantum_storage_redis` to your list
of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quantum_storage_redis, "~> 0.0.1"}
  ]
end
```

2. Start Adapter under supervision tree:

```elixir
children = [
  ...
  # Here you need provide options for Redix adapter. Note that 
  # redix itself will be started under name postfixed with `Redix`
  # For more options please see redix docs
  {QuantumStorageRedis, name: :quantum_storage, host: "localhost", port: 6379}
  ...
]
```

3. Enable storage adapter for your scheduler, add this to your `config.exs`:

```elixir
import Config

config :acme, Acme.Scheduler,
  storage: QuantumStorageRedis
```