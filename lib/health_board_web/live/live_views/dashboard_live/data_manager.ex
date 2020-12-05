defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.DashboardData
  alias Phoenix.LiveView

  @params %{
    "births_child_mass" => :atom,
    "births_child_masses" => {:list, :atom},
    "births_child_sex" => :atom,
    "births_deliveries" => {:list, :atom},
    "births_delivery" => :atom,
    "births_gestation_duration" => :atom,
    "births_gestation_durations" => {:list, :atom},
    "births_location_context" => :integer,
    "births_location" => :atom,
    "births_locations" => {:list, :atom},
    "births_mother_age" => :atom,
    "births_mother_ages" => {:list, :atom},
    "births_prenatal_consultation" => :atom,
    "births_prenatal_consultations" => {:list, :atom},
    "death_context" => :integer,
    "death_investigation" => :atom,
    "death_location_context" => :integer,
    "death_type" => :atom,
    "dengue_classification" => :atom,
    "dengue_classifications" => {:list, :atom},
    "dengue_serotype" => :atom,
    "dengue_serotypes" => {:list, :atom},
    "geo_cities" => {:list, :integer},
    "geo_city" => :integer,
    "geo_country" => :integer,
    "geo_health_region" => :integer,
    "geo_health_regions" => {:list, :integer},
    "geo_region" => :integer,
    "geo_regions" => {:list, :integer},
    "geo_state" => :integer,
    "geo_states" => {:list, :integer},
    "morbidities_location_context" => :integer,
    "person_age_group" => :atom,
    "person_age_groups" => {:list, :atom},
    "person_race" => :atom,
    "person_races" => {:list, :atom},
    "person_sex" => :atom,
    "time_date_period" => {:list, :date},
    "time_date" => :date,
    "time_week_period" => {:list, :integer},
    "time_week" => :integer,
    "time_year_period" => {:list, :integer},
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

      filters =
        params
        |> Enum.reduce(%{}, &parse_filter/2)
        |> Map.drop(disabled_filters)

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

  defp parse_filter({param_key, param_value}, filters) do
    case Map.get(@params, param_key) do
      nil -> filters
      type -> parse_value(filters, param_key, type, param_value)
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
