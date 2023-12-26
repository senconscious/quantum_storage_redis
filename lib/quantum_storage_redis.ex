defmodule QuantumStorageRedis do
  @moduledoc """
  `Redis` based implementation of a `Quantum.Storage`.
  """

  use GenServer

  alias QuantumStorageRedis.State
  alias QuantumStorageRedis.Utils

  require Logger

  @behaviour Quantum.Storage

  @supported_redix_options [
    :host,
    :port,
    :database,
    :username,
    :password,
    :timeout,
    :sync_connect,
    :exit_on_disconnection,
    :backoff_initial,
    :backoff_max,
    :ssl,
    :name,
    :socket_opts,
    :hibernate_after,
    :spawn_opt,
    :debug,
    :sentinel
  ]

  @doc false
  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, opts)

  @doc false
  @impl GenServer
  def init(opts) do
    opts =
      opts
      |> Keyword.update!(:name, &Module.concat(&1, Redix))
      |> Keyword.take(@supported_redix_options)

    {:ok, conn} = Redix.start_link(opts)

    {:ok, %State{conn: conn}}
  end

  @doc false
  @impl Quantum.Storage
  def jobs(storage_pid) do
    GenServer.call(storage_pid, :jobs)
  end

  @doc false
  @impl Quantum.Storage
  def add_job(storage_pid, job), do: GenServer.cast(storage_pid, {:add_job, job})

  @doc false
  @impl Quantum.Storage
  def delete_job(storage_pid, job_name), do: GenServer.cast(storage_pid, {:delete_job, job_name})

  @doc false
  @impl Quantum.Storage
  def update_job_state(storage_pid, job_name, state),
    do: GenServer.cast(storage_pid, {:update_job_state, job_name, state})

  @doc false
  @impl Quantum.Storage
  def last_execution_date(storage_pid), do: GenServer.call(storage_pid, :last_execution_date)

  @doc false
  @impl Quantum.Storage
  def update_last_execution_date(storage_pid, last_execution_date),
    do: GenServer.cast(storage_pid, {:update_last_execution_date, last_execution_date})

  @doc false
  @impl Quantum.Storage
  def purge(storage_pid), do: GenServer.cast(storage_pid, :purge)

  @doc false
  @impl GenServer
  def handle_cast({:add_job, job}, %State{conn: conn} = state) do
    Redix.command!(conn, [
      "MSET",
      Utils.encode_job_name(job.name),
      Utils.encode_job!(job),
      "init_jobs",
      1
    ])

    Logger.debug(fn ->
      "[#{inspect(Node.self())}][#{__MODULE__}] inserting [#{inspect({job.name, job})}] into Redis #{inspect(conn)}"
    end)

    {:noreply, state}
  end

  def handle_cast({:delete_job, job_name}, %State{conn: conn} = state) do
    Redix.command!(conn, ["DEL", Utils.encode_job_name(job_name)])

    {:noreply, state}
  end

  def handle_cast({:update_job_state, job_name, job_state}, %State{conn: conn} = state) do
    encoded_job_name = Utils.encode_job_name(job_name)

    conn
    |> Redix.command!(["GET", encoded_job_name])
    |> Utils.decode_job!()
    |> Map.put(:state, job_state)
    |> Utils.encode_job!()
    |> then(&Redix.command!(conn, ["SET", encoded_job_name, &1]))

    {:noreply, state}
  end

  def handle_cast(
        {:update_last_execution_date, last_execution_date},
        %State{conn: conn} = state
      ) do
    Redix.command!(conn, ["SET", "last_execution_date", last_execution_date])

    {:noreply, state}
  end

  def handle_cast(:purge, %State{conn: conn} = state) do
    Redix.command!(conn, ["FLUSHDB"])

    {:noreply, state}
  end

  @doc false
  @impl GenServer
  def handle_call(:jobs, _from, %State{conn: conn} = state) do
    case Redix.command!(conn, ["GET", "init_jobs"]) do
      nil ->
        {:reply, :not_applicable, state}

      _ ->
        jobs = list_jobs(conn)

        {:reply, jobs, state}
    end
  end

  def handle_call(:last_execution_date, _from, %State{conn: conn} = state) do
    case Redix.command!(conn, ["GET", "last_execution_date"]) do
      nil ->
        {:reply, :unknown, state}

      datetime ->
        {:reply, NaiveDateTime.from_iso8601!(datetime), state}
    end
  end

  defp list_jobs(conn) do
    keys =
      conn
      |> Redix.command!(["KEYS", "*"])
      |> Enum.filter(&(&1 not in ["init_jobs", "last_execution_date"]))

    case keys do
      [] ->
        []

      keys when is_list(keys) ->
        conn
        |> Redix.command!(["MGET" | keys])
        |> Enum.map(&Utils.decode_job!/1)
    end
  end
end
