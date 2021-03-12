defmodule HealthBoardWeb.DashboardLive.ElementsData do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoardWeb.DashboardLive.Components.DataWrapper
  alias HealthBoardWeb.Helpers.Geo
  alias Phoenix.LiveView

  @cache_table :health_board_web_dashboard_live__data_cache

  @spec apply_and_cache(module, atom, list, keyword) :: any
  def apply_and_cache(module, function, params, opts \\ []) do
    case Keyword.fetch(opts, :apply) do
      {:ok, true} -> do_apply_and_cache(module, function, params)
      _from_database -> get_cache_or_apply(module, function, params)
    end
  rescue
    error ->
      Logger.error("""
      Failed to apply and cache: #{Exception.message(error)}
      #{inspect({module, function, params, opts}, pretty: true)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      """)

      case Keyword.fetch(opts, :default) do
        {:ok, fun} when is_function(fun) -> fun.()
        {:ok, default} -> default
        :error -> nil
      end
  end

  defp do_apply_and_cache(module, function, params) do
    value = apply(module, function, params)
    :ets.insert(@cache_table, {{module, function, params}, value})
    value
  end

  defp get_cache_or_apply(module, function, params) do
    case :ets.lookup(@cache_table, {module, function, params}) do
      [{_key, value}] -> value
      _records -> do_apply_and_cache(module, function, params)
    end
  end

  @spec emit(LiveView.Socket.t(), map, keyword) :: :ok
  def emit(socket, element, opts \\ []), do: GenServer.cast(__MODULE__, {:emit, {socket.root_pid, element, opts}})

  @impl GenServer
  @spec handle_cast(any, :empty) :: {:noreply, :empty}
  def handle_cast({:emit, {pid, element, opts}}, state) do
    Process.send_after(self(), {:emit, {pid, element, opts}}, Keyword.get(opts, :after, 1_000))
    {:noreply, state}
  end

  def handle_cast(:purge, state) do
    :ets.delete_all_objects(@cache_table)
    {:noreply, state}
  end

  @impl GenServer
  @spec handle_info(any, :empty) :: {:noreply, :empty}
  def handle_info({:emit, {pid, element, opts}}, state) do
    handle_emit(pid, element, opts)
    {:noreply, state}
  end

  @impl GenServer
  @spec init(any) :: {:ok, :empty}
  def init(_args) do
    :ets.new(@cache_table, [:set, :public, :named_table])
    Geo.init()
    {:ok, :empty}
  end

  @spec start_link(keyword) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(args) do
    GenServer.start(__MODULE__, args, name: __MODULE__)
  end

  @spec purge :: :ok
  def purge, do: GenServer.cast(__MODULE__, :purge)

  defp handle_emit(pid, %{children: children, filters: filters} = element, data \\ %{}, opts) do
    filters = Enum.into(filters, %{}, &{&1[:sid], &1[:value]})
    data = Enum.reduce(element.data, data, &fetch_data(&1, &2, filters, opts))

    emit_data(pid, element, data)

    if is_list(children) do
      Enum.each(children, &handle_emit(pid, &1.child, data, opts))
    end
  end

  defp fetch_data(element, data, filters, opts) do
    %{field: field, data_module: module, data_function: function, data_params: params} = element

    __MODULE__
    |> Module.concat(module)
    |> apply(String.to_atom(function), [data, String.to_atom(field), URI.decode_query(params || ""), filters, opts])
  rescue
    error ->
      Logger.error("""
      Failed to request data: #{Exception.message(error)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      #{inspect(element, pretty: true)}
      """)

      data
  end

  defp emit_data(pid, element, data) do
    %{component_module: module, component_function: function, component_params: params} = element

    __MODULE__.Components
    |> Module.concat(module)
    |> apply(String.to_atom(function), [data, URI.decode_query(params || "")])
    |> case do
      {:ok, {:emit, data}} ->
        DataWrapper.fetch(pid, element.id, data)

      {:ok, {:emit_and_hook, {hook, hook_data}}} ->
        DataWrapper.fetch_and_hook(pid, element.id, %{ready?: true}, hook, hook_data)

      {:ok, {:emit_and_hook, {data, hook, hook_data}}} ->
        DataWrapper.fetch_and_hook(pid, element.id, data, hook, hook_data)

      _result ->
        DataWrapper.fetch(pid, element.id, %{error?: true})
    end
  rescue
    error ->
      Logger.error("""
      Failed to request data: #{Exception.message(error)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      #{inspect(element, pretty: true)}
      """)

      DataWrapper.fetch(pid, element.id, %{ready?: true})
  end
end
