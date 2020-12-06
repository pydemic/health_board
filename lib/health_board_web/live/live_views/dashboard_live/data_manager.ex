defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.DashboardData
  alias Phoenix.LiveView

  @params %{
    "geo_cities" => {:list, :integer},
    "geo_city" => :integer,
    "geo_country" => :integer,
    "geo_health_region" => :integer,
    "geo_health_regions" => {:list, :integer},
    "geo_region" => :integer,
    "geo_regions" => {:list, :integer},
    "geo_state" => :integer,
    "geo_states" => {:list, :integer},
    "morbidity_context" => :integer,
    "morbidity_contexts" => {:list, :integer},
    "time_from_week" => :integer,
    "time_to_week" => :integer,
    "time_week" => :integer,
    "time_from_year" => :integer,
    "time_to_year" => :integer,
    "time_year" => :integer
  }

  @spec initial_data(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def initial_data(socket, params) do
    case Info.Dashboards.get(params["id"] || "analytic") do
      {:ok, dashboard} -> LiveView.assign(socket, :dashboard, dashboard)
      _not_found -> socket
    end
  end

  @spec update(LiveView.Socket.t(), map) :: LiveView.Socket.t()
  def update(socket, params) do
    if Map.has_key?(socket.assigns, :dashboard) do
      %{
        id: id,
        name: name,
        description: description,
        disabled_filters: disabled_filters
      } = dashboard = Info.Dashboards.preload(socket.assigns.dashboard)

      disabled_filters = Enum.map(disabled_filters, & &1.filter)

      filters = parse_filters(params)

      sections =
        dashboard
        |> DashboardData.new(filters)
        |> DashboardData.fetch()
        |> DashboardData.assign()

      data = %{
        id: id,
        name: name,
        description: description,
        filters: filters,
        disabled_filters: disabled_filters,
        sections: sections
      }

      LiveView.assign(socket, :dashboard, data)
    else
      socket
    end
  end

  @spec parse_filters(map, list(atom)) :: map
  def parse_filters(params, disabled_filters \\ []) do
    Enum.reduce(params, %{}, &parse_filter(&1, &2, disabled_filters))
  end

  defp parse_filter({param_key, param_value}, filters, disabled_filters) do
    if param_key in disabled_filters do
      filters
    else
      case Map.get(@params, param_key) do
        nil -> filters
        type -> parse_value(filters, param_key, type, param_value)
      end
    end
  end

  defp parse_value(filters, filter_id, type, value) do
    case do_parse_value(type, value) do
      nil -> filters
      value -> Map.put(filters, filter_id, value)
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
