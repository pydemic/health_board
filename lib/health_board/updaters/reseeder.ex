defmodule HealthBoard.Updaters.Reseeder do
  use GenServer

  require Logger

  @server_name :updater_reseeder

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    GenServer.start(__MODULE__, nil, name: @server_name)
  end

  @spec reseed(module, keyword) :: :ok | {:error, {any, Exception.stacktrace()}}
  def reseed(module, opts) do
    GenServer.call(@server_name, {:reseed, {module, opts}}, :infinity)
  end

  @impl GenServer
  @spec init(any) :: {:ok, nil}
  def init(_args) do
    {:ok, nil}
  end

  @impl GenServer
  @spec handle_call(any, any, any) :: {:reply, any, any}
  def handle_call({:reseed, {module, opts}}, _from, state) do
    {:reply, do_reseed(module, opts), state}
  end

  defp do_reseed(module, opts) do
    module.reseed!(opts)
    :ok
  rescue
    error -> {:error, {error, __STACKTRACE__}}
  end
end
