defmodule QuantumStorageRedis.State do
  @moduledoc false

  @type t :: %__MODULE__{conn: %Redix.Connection{}}

  @enforce_keys [:conn]
  defstruct @enforce_keys
end
