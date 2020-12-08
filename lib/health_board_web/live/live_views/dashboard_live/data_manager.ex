defmodule HealthBoardWeb.DashboardLive.DataManager do
  require Logger

  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.DashboardData
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def initial_data(socket, params) do
    if socket.changed[:dashboard] == true or is_nil(socket.assigns[:dashboard]) do
      case Info.Dashboards.get(params["id"] || "analytic") do
        {:ok, dashboard} -> LiveView.assign(socket, :dashboard, Info.Dashboards.preload(dashboard))
        _not_found -> socket
      end
    else
      socket
    end
  end

  @spec update(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def update(%{assigns: assigns} = socket, params) do
    if Map.has_key?(assigns, :dashboard) do
      %{
        id: id,
        name: name,
        description: description,
        disabled_filters: disabled_filters,
        sections: sections
      } = assigns.dashboard

      disabled_filters = Enum.map(disabled_filters, & &1.filter)

      query_filters = parse_filters(params)

      data = %{
        id: id,
        name: name,
        description: description,
        query_filters: query_filters,
        disabled_filters: disabled_filters,
        sections: fetch_sections(id, sections, query_filters, socket.root_pid)
      }

      LiveView.assign(socket, :dashboard, data)
    else
      socket
    end
  end

  defp fetch_sections(id, sections, query_filters, root_pid) do
    id
    |> DashboardData.fetch(%{query_filters: query_filters, pid: root_pid})
    |> DashboardData.sections(sections)
  rescue
    error ->
      Logger.error(
        "Failed to build dashboard #{id} data.\n" <>
          Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
      )

      []
  end

  @params %{
    "cities" => {:list, :integer},
    "city" => :integer,
    "country" => :integer,
    "health_region" => :integer,
    "health_regions" => {:list, :integer},
    "region" => :integer,
    "regions" => {:list, :integer},
    "state" => :integer,
    "states" => {:list, :integer},
    "morbidity_context" => :integer,
    "morbidity_contexts" => {:list, :integer},
    "from_week" => :integer,
    "to_week" => :integer,
    "week" => :integer,
    "from_year" => :integer,
    "to_year" => :integer,
    "year" => :integer
  }

  @params_keys Map.keys(@params)

  @spec parse_filters(map, list(atom)) :: map
  def parse_filters(params, disabled_filters \\ []) do
    params
    |> Map.take(@params_keys)
    |> Map.drop(disabled_filters)
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
    end
  rescue
    _error -> nil
  end
end
