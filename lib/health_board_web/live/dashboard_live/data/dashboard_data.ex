defmodule HealthBoardWeb.DashboardLive.DashboardsData do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards.Elements

  @cache_table :dashboards_cache

  @spec start_link(any) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(_args) do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @spec fetch(integer, map) :: {:ok, map} | {:error, atom}
  def fetch(id, params), do: GenServer.call(__MODULE__, {:fetch, {id, params}})

  @impl GenServer
  @spec init(any) :: {:ok, :empty}
  def init(_args) do
    :ets.new(@cache_table, [:set, :public, :named_table])

    {:ok, :empty}
  end

  @impl GenServer
  @spec handle_call(any, {pid, any}, :empty) :: {:reply, any, :empty}
  def handle_call({:fetch, {id, params}}, _from, state) do
    case :ets.lookup(@cache_table, id) do
      [{_id, dashboard}] ->
        {:reply, {:ok, fetch_params(dashboard, params)}, state}

      _result ->
        case Elements.fetch_dashboard(id) do
          {:ok, dashboard} ->
            :ets.insert(@cache_table, {id, dashboard})
            {:reply, {:ok, fetch_params(dashboard, params)}, state}

          _error ->
            {:reply, {:error, :not_found}, state}
        end
    end
  end

  defp fetch_params(dashboard, params) do
    other_dashboards = other_dashboards(dashboard.id)

    parse_element(dashboard, [], [], params, other_dashboards)
  end

  defp other_dashboards(id) do
    case Elements.list_other_dashboards(id) do
      {:ok, dashboards} -> dashboards
      _result -> []
    end
  end

  defp parse_element(%{children: children} = element, filters, sources, params, other_dashboards) do
    filters = filters ++ parse_filters(element.filters, params)
    sources = parse_sources(element.sources) ++ sources

    properties = [
      children: parse_children(children, filters, sources, params),
      filters: filters,
      sources: sources
    ]

    if other_dashboards != [] do
      struct(element, properties ++ [other_dashboards: other_dashboards])
    else
      struct(element, properties)
    end
  end

  defp parse_filters(filters, params) do
    if is_list(filters) do
      Enum.map(filters, &parse_filter(&1, params))
    else
      []
    end
  end

  defp parse_filter(%{filter: filter} = element_filter, params) do
    default = element_filter.default || filter.default

    Map.merge(
      fetch_filter(element_filter, params, default),
      %{
        title: filter.title,
        description: filter.description,
        disabled: element_filter.disabled || filter.disabled
      }
    )
  end

  defp fetch_filter(%{options_module: nil, options_params: options_params, filter: filter}, params, default) do
    if is_nil(options_params) do
      fetch_filter(filter, params, default)
    else
      fetch_filter(filter, Map.merge(params, URI.decode_query(options_params)), default)
    end
  end

  defp fetch_filter(filter, params, default) do
    HealthBoardWeb.DashboardLive.ElementsFiltersData.fetch(filter, params, default)
  end

  defp parse_sources(sources) do
    if is_list(sources) do
      sources
    else
      []
    end
  end

  defp parse_children(children, filters, sources, params) do
    if is_list(children) do
      Enum.map(children, fn %{child: child} = element_child ->
        struct(element_child, child: parse_element(child, filters, sources, params, []))
      end)
    else
      children
    end
  end
end
