defmodule QuantumStorageRedis.Utils do
  @moduledoc """
  Provides utilities for encoding/decoding Quantum.Job struct
  """

  def encode_job!(job) when is_struct(job) do
    :erlang.term_to_binary(job)
  end

  def decode_job!(job) when is_binary(job) do
    :erlang.binary_to_term(job)
  end

  def encode_job_name(name) when is_atom(name) do
    Atom.to_string(name)
  end

  def encode_job_name(name) when is_reference(name) do
    :erlang.term_to_binary(name)
  end
end
