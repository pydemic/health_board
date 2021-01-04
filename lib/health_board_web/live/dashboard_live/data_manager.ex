defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.{Geo, Info}
  alias HealthBoardWeb.DashboardLive.DashboardData
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def initial_data(socket, params) do
    socket = LiveView.assign_new(socket, :data, fn -> %{} end)

    if socket.changed[:dashboard] == true or is_nil(socket.assigns[:dashboard]) do
      socket = LiveView.assign(socket, filters_assigns(parse_filters(params), socket))

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
      if socket.changed[:filters] do
        LiveView.assign(socket, :changed_filters, true)
      else
        params
        |> parse_filters()
        |> filters_assigns(socket)
        |> assign_changed_filters(socket)
      end
      |> DashboardData.fetch()
    else
      socket
    end
  end

  @params %{
    "id" => :string,
    "index" => :integer,
    "city" => :integer,
    "health_region" => :integer,
    "state" => :integer,
    "region" => :integer,
    "date" => :date
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
      :date -> Date.from_iso8601!(value)
      :integer -> String.to_integer(value)
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

  @first_case_date Date.from_erl!({2020, 02, 26})
  @nil_selection {"Não selecionado", nil}

  defp filters_assigns(filters, socket) do
    today = Date.utc_today()
    filters = Map.merge(%{id: "flu_syndrome", date: today}, filters)

    unless is_nil(socket.root_pid) do
      send(
        socket.root_pid,
        {:exec_and_emit, & &1, %{id: "date", from: @first_case_date, to: today, date: filters.date}, {:picker, :date}}
      )
    end

    region = filters[:region]
    state = filters[:state]
    health_region = filters[:health_region]

    region_options = [@nil_selection | location_options(:region)]
    state_options = [@nil_selection | location_options(:state, [region, 76])]
    health_region_options = [@nil_selection | location_options(:health_region, [state])]
    city_options = [@nil_selection | location_options(:city, [health_region, state])]

    %{
      filters: filters,
      filters_options: %{
        region: region_options,
        state: state_options,
        health_region: health_region_options,
        city: city_options
      }
    }
  end

  defp location_options(context) do
    [context: Geo.Locations.context(context), order_by: [asc: :name]]
    |> Geo.Locations.list_by()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp location_options(context, [parent_id | parents_ids]) do
    if is_nil(parent_id) do
      if Enum.empty?(parents_ids) do
        []
      else
        location_options(context, parents_ids)
      end
    else
      parent_id
      |> Geo.Locations.list_children(context)
      |> Enum.map(&{&1.name, &1.id})
      |> Enum.sort(fn {name1, _id1}, {name2, _id2} -> name1 <= name2 end)
    end
  end

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
