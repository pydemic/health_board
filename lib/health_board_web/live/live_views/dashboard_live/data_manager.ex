defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.{Geo, Info}
  alias HealthBoardWeb.DashboardLive.DashboardData
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def initial_data(socket, params) do
    socket = LiveView.assign_new(socket, :data, fn -> %{} end)

    if socket.changed[:dashboard] == true or is_nil(socket.assigns[:dashboard]) do
      socket = LiveView.assign(socket, filters_assigns(parse_filters(params)))

      case Info.Dashboards.get(socket.assigns.filters.id) do
        {:ok, dashboard} -> LiveView.assign(socket, :dashboard, Info.Dashboards.preload(dashboard))
        _not_found -> socket
      end
    else
      socket
    end
  end

  @spec update(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def update(socket, params) do
    if Map.has_key?(socket.assigns, :dashboard) do
      socket =
        if socket.changed[:filters] do
          LiveView.assign(socket, :changed_filters, true)
        else
          params
          |> parse_filters()
          |> filters_assigns()
          |> assign_changed_filters(socket)
        end

      DashboardData.fetch(socket)
    else
      socket
    end
  end

  @params %{
    "id" => :string,
    "index" => :integer,
    "cities" => {:list, :integer},
    "city" => :integer,
    "health_region" => :integer,
    "health_regions" => {:list, :integer},
    "state" => :integer,
    "from_year" => :integer,
    "to_year" => :integer,
    "year" => :integer
  }

  @params_keys Map.keys(@params)

  @spec parse_filters(map) :: map
  def parse_filters(params) do
    params
    |> Map.take(@params_keys)
    |> Enum.reduce(%{}, &parse_filter/2)
  end

  defp parse_filter({param_key, param_value}, filters) do
    case Map.get(@params, param_key) do
      nil -> filters
      type -> parse_value(filters, param_key, type, param_value)
    end
  end

  defp parse_value(filters, filter_id, type, value) do
    case do_parse_value(type, value) do
      nil -> filters
      value -> Map.put(filters, String.to_atom(filter_id), value)
    end
  end

  defp do_parse_value(type, value) do
    case type do
      :atom -> String.to_existing_atom(value)
      :date -> Date.from_iso8601!(value)
      :integer -> String.to_integer(value)
      {:list, type} -> Enum.map(String.split(value, ","), &do_parse_value(type, &1))
      :string -> value
    end
  rescue
    _error -> nil
  end

  @spec filters_changed?(map | true, atom | list(atom) | nil) :: boolean
  def filters_changed?(changed_filters, key_or_keys \\ nil)
  def filters_changed?(true, _key_or_keys), do: true
  def filters_changed?(changed_filters, nil) when is_map(changed_filters), do: true
  def filters_changed?(changed_filters, key) when is_atom(key), do: Map.has_key?(changed_filters, key)
  def filters_changed?(changed_filters, keys) when is_list(keys), do: Enum.any?(changed_filters, &(elem(&1, 0) in keys))

  @spec add_filter_change(map | true, atom | list(atom)) :: map | true
  def add_filter_change(changed_filters, key_or_keys) do
    if changed_filters == true do
      true
    else
      case key_or_keys do
        keys when is_list(keys) -> Enum.reduce(keys, changed_filters, &Map.put(&2, &1, true))
        key -> Map.put(changed_filters, key, true)
      end
    end
  end

  @nil_selection {"Não selecionado", nil}

  defp filters_assigns(filters) do
    current_year = Date.utc_today().year

    %{from_year: from_year, to_year: to_year} =
      filters =
      filters
      |> Map.put_new(:id, "demographic")
      |> Map.put_new(:year, current_year)
      |> Map.put_new(:from_year, 2000)
      |> Map.put_new(:to_year, current_year)

    year_options = Enum.zip(2000..current_year, 2000..current_year)
    from_year_options = Enum.zip(2000..(to_year - 1), 2000..(to_year - 1))
    to_year_options = Enum.zip((from_year + 1)..current_year, (from_year + 1)..current_year)

    state = filters[:state]
    health_region = filters[:health_region]

    state? = not is_nil(state)
    health_region? = state? and not is_nil(health_region)

    state_options = [@nil_selection | location_options(:state)]
    health_region_options = [@nil_selection | if(state?, do: location_options(state, :health_region), else: [])]
    city_options = [@nil_selection | cities_options(state?, state, health_region?, health_region)]

    %{
      filters: filters,
      filters_options: %{
        year: year_options,
        from_year: from_year_options,
        to_year: to_year_options,
        state: state_options,
        health_region: health_region_options,
        city: city_options
      }
    }
  end

  defp location_options(context) do
    [context: Geo.Locations.context!(context), order_by: [asc: :name]]
    |> Geo.Locations.list_by()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp location_options(parent_id, context) do
    parent_id
    |> Geo.Locations.list_children(context)
    |> Enum.map(&{&1.name, &1.id})
  end

  defp cities_options(_state?, _state, true, health_region), do: location_options(health_region, :city)
  defp cities_options(true, state, _health_region?, _health_region), do: location_options(state, :city)
  defp cities_options(_state?, _state, _health_region?, _health_region), do: []

  defp assign_changed_filters(%{filters: new_filters} = assigns, %{assigns: %{filters: filters}} = socket) do
    changed_filters =
      filters
      |> Map.keys()
      |> Kernel.++(Map.keys(new_filters))
      |> Enum.uniq()
      |> Enum.map(&{&1, filters[&1] != new_filters[&1]})
      |> Enum.reject(&(elem(&1, 1) == false))
      |> Enum.into(%{})

    LiveView.assign(socket, Map.put(assigns, :changed_filters, changed_filters))
  end
end
