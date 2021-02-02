defmodule HealthBoardWeb.DashboardLive.ElementsData do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoardWeb.DashboardLive.Components.DataWrapper
  alias Phoenix.LiveView

  @cache_table :health_board_web_dashboard_live__data_cache

  @spec cache_table :: atom
  def cache_table, do: @cache_table

  @spec start_link(any) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(_args) do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @spec request(LiveView.Socket.t(), map) :: :ok
  def request(socket, dashboard), do: GenServer.cast(__MODULE__, {:request_after, {socket.root_pid, dashboard, 1_000}})

  @impl GenServer
  @spec init(any) :: {:ok, :empty}
  def init(_args) do
    :ets.new(@cache_table, [:set, :public, :named_table])

    {:ok, :empty}
  end

  @impl GenServer
  @spec handle_cast(any, :empty) :: {:noreply, :empty}
  def handle_cast({:request, {pid, dashboard, data}}, state) do
    request_data(pid, dashboard, data)
    {:noreply, state}
  end

  def handle_cast({:request_after, {pid, dashboard, after_milliseconds}}, state) do
    Process.send_after(self(), {:request, {pid, dashboard}}, after_milliseconds)
    {:noreply, state}
  end

  @impl GenServer
  @spec handle_info(any, :empty) :: {:noreply, :empty}
  def handle_info({:request, {pid, dashboard}}, state) do
    request_data(pid, dashboard)
    {:noreply, state}
  end

  defp request_data(pid, %{children: children, filters: filters} = element, data \\ %{}) do
    filters = Enum.into(filters, %{}, &{&1[:name], &1[:value]})
    data = Enum.reduce(element.data, data, &do_request_data(&1, &2, filters))

    if is_list(children) do
      Enum.each(children, &GenServer.cast(__MODULE__, {:request, {pid, &1.child, data}}))
    end

    handle_component_data(pid, element, data)
  end

  defp do_request_data(element, data, filters) do
    %{field: field, data_module: module, data_function: function, data_params: params} = element

    __MODULE__
    |> Module.concat(module)
    |> apply(String.to_atom(function), [data, String.to_atom(field), URI.decode_query(params || ""), filters])
  rescue
    error ->
      Logger.error("""
      Failed to request data: #{Exception.message(error)}
      #{inspect(element, pretty: true)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      """)

      data
  end

  defp handle_component_data(pid, element, data) do
    %{component_module: module, component_function: function, component_params: params} = element

    __MODULE__.Components
    |> Module.concat(module)
    |> apply(String.to_atom(function), [data, URI.decode_query(params || "")])
    |> case do
      {:ok, {:emit, data}} -> DataWrapper.fetch(pid, element.id, data)
      _result -> :ok
    end
  rescue
    error ->
      Logger.error("""
      Failed to request data: #{Exception.message(error)}
      #{inspect(element, pretty: true)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      """)
  end
end
