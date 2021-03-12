defmodule HealthBoardWeb.DashboardLive.DashboardsData do
  use GenServer, restart: :permanent
  require Logger
  alias HealthBoard.Contexts.Dashboards.Elements

  @cache_table :dashboards_cache

  @valid_params_keys [
    "dark_mode",
    "date",
    "group_index",
    "id",
    "location",
    "period_from",
    "period_to",
    "period_type",
    "show_options"
  ]

  @type t :: %__MODULE__{
          default_dashboard_id: integer,
          organizations: list({String.t(), String.t()}),
          version: String.t()
        }

  defstruct default_dashboard_id: 1,
            organizations: [{"https://www.paho.org/pt/brasil", "/images/logo_paho.svg"}],
            version: "0.0.1"

  @spec start_link(keyword) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(args) do
    GenServer.start(__MODULE__, args, name: __MODULE__)
  end

  @spec fetch(integer, map, keyword) :: {:ok, map} | {:error, atom}
  def fetch(id, params, opts \\ []), do: GenServer.call(__MODULE__, {:fetch, {id, params, opts}}, 20_000)

  @spec purge :: :ok
  def purge, do: GenServer.cast(__MODULE__, :purge)

  @impl GenServer
  @spec init(keyword) :: {:ok, t()}
  def init(args) do
    :ets.new(@cache_table, [:set, :public, :named_table])
    {:ok, struct(__MODULE__, args)}
  end

  @impl GenServer
  @spec handle_call(any, {pid, any}, t()) :: {:reply, any, t()}
  def handle_call({:fetch, {id, params, opts}}, _from, state) do
    id = if is_nil(id), do: state.default_dashboard_id, else: id
    {:reply, fetch_dashboard(id, params, opts, state), state}
  end

  @impl GenServer
  @spec handle_cast(any, t()) :: {:noreply, t()}
  def handle_cast(:purge, state) do
    :ets.delete_all_objects(@cache_table)
    {:noreply, state}
  end

  defp fetch_dashboard(id, params, opts, state) do
    case Keyword.fetch(opts, :from_database) do
      {:ok, true} -> fetch_from_database(id, params, state)
      _result -> fetch_from_ets(id, params, state)
    end
  end

  defp fetch_from_ets(id, params, state) do
    case :ets.lookup(@cache_table, id) do
      [{_id, dashboard}] -> {:ok, fetch_params(dashboard, params, state)}
      _result -> fetch_from_database(id, params, state)
    end
  end

  defp fetch_from_database(id, params, state) do
    case Elements.fetch_dashboard(id) do
      {:ok, dashboard} ->
        :ets.insert(@cache_table, {id, dashboard})
        {:ok, fetch_params(dashboard, params, state)}

      _error ->
        {:error, :not_found}
    end
  end

  defp fetch_params(dashboard, params, state) do
    params = parse_params(params)

    dashboard
    |> fetch_additional_data(params, state)
    |> parse_element([], [], params)
  end

  defp parse_params(params) do
    Map.take(params, @valid_params_keys)
  end

  defp fetch_additional_data(dashboard, params, %{organizations: organizations, version: version}) do
    struct(dashboard,
      other_dashboards: Elements.list_other_dashboards(dashboard),
      organizations: organizations,
      version: version,
      group_index: fetch_group_index(params)
    )
  end

  defp fetch_group_index(params) do
    case Map.fetch(params, "group_index") do
      {:ok, group_index} -> String.to_integer(group_index)
      :error -> 0
    end
  rescue
    _error -> 0
  end

  defp parse_element(%{children: children} = element, filters, sources, params) do
    filters = filters ++ parse_filters(element.filters, params)
    sources = parse_sources(element.sources) ++ sources

    struct(element,
      children: parse_children(children, filters, sources, params),
      filters: filters,
      params: params,
      sources: sources,
      dark_mode: params["dark_mode"] == "true",
      show_options: params["show_options"] != "false"
    )
  end

  defp parse_filters(filters, params) do
    if is_list(filters) do
      Enum.map(filters, &parse_filter(&1, params))
    else
      []
    end
  end

  defp parse_filter(%{filter: filter} = element_filter, params) do
    element_filter
    |> fetch_filter(params, element_filter.default || filter.default)
    |> Map.merge(%{
      sid: filter.sid,
      name: element_filter.name || filter.name,
      description: element_filter.description || filter.description,
      disabled: element_filter.disabled || filter.disabled
    })
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
        struct(element_child, child: parse_element(child, filters, sources, params))
      end)
    else
      children
    end
  end
end
