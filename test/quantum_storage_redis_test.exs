defmodule QuantumStorageRedisTest do
  use ExUnit.Case
  doctest QuantumStorageRedis

  defmodule Scheduler do
    @moduledoc false

    use Quantum, otp_app: :quantum_storage_redis
  end

  setup %{line: line} do
    storage =
      start_supervised!(
        {QuantumStorageRedis,
         name: Module.concat(__MODULE__, "#{line}"), host: "localhost", port: 6379, database: 1}
      )

    assert :ok = QuantumStorageRedis.purge(storage)

    {:ok, storage: storage}
  end

  describe "purge/1" do
    test "purges correct module", %{storage: storage} do
      assert :ok = QuantumStorageRedis.add_job(storage, Scheduler.new_job())
      assert :ok = QuantumStorageRedis.purge(storage)
      assert :not_applicable = QuantumStorageRedis.jobs(storage)
    end
  end

  describe "add_job/2" do
    test "adds job", %{storage: storage} do
      job = Scheduler.new_job()
      assert :ok = QuantumStorageRedis.add_job(storage, job)
      assert [^job] = QuantumStorageRedis.jobs(storage)
    end
  end

  describe "delete_job/2" do
    test "deletes job", %{storage: storage} do
      job = Scheduler.new_job()
      assert :ok = QuantumStorageRedis.add_job(storage, job)
      assert :ok = QuantumStorageRedis.delete_job(storage, job.name)
      assert [] = QuantumStorageRedis.jobs(storage)
    end

    test "does not fail when deleting unknown job", %{storage: storage} do
      job = Scheduler.new_job()
      assert :ok = QuantumStorageRedis.add_job(storage, job)

      assert :ok = QuantumStorageRedis.delete_job(storage, make_ref())
    end
  end

  describe "update_job_state/2" do
    test "updates job", %{storage: storage} do
      job = Scheduler.new_job()
      assert :ok = QuantumStorageRedis.add_job(storage, job)
      assert :ok = QuantumStorageRedis.update_job_state(storage, job.name, :inactive)
      assert [%{state: :inactive}] = QuantumStorageRedis.jobs(storage)
    end

    test "does not fail when updating unknown job", %{storage: storage} do
      job = Scheduler.new_job()
      assert :ok = QuantumStorageRedis.add_job(storage, job)

      assert :ok = QuantumStorageRedis.update_job_state(storage, make_ref(), :inactive)
    end
  end

  describe "update_last_execution_date/2" do
    test "sets time on scheduler", %{storage: storage} do
      date = NaiveDateTime.utc_now()
      assert :ok = QuantumStorageRedis.update_last_execution_date(storage, date)
      assert ^date = QuantumStorageRedis.last_execution_date(storage)
    end
  end

  describe "last_execution_date/1" do
    test "gets time", %{storage: storage} do
      date = NaiveDateTime.utc_now()
      assert :ok = QuantumStorageRedis.update_last_execution_date(storage, date)
      assert ^date = QuantumStorageRedis.last_execution_date(storage)
    end

    test "get unknown otherwise", %{storage: storage} do
      assert :unknown = QuantumStorageRedis.last_execution_date(storage)
    end
  end
end
