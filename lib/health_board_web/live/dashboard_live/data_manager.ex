defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def initial_data(socket, %{"dashboard_id" => id}) do
    case Info.Dashboards.get(id, preload_all?: true) do
      {:ok, dashboard} -> prepare_dashboard(socket, dashboard)
      _not_found -> LiveView.redirect(socket, to: Routes.home_path(socket, :index))
    end
  end

  @spec update(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def update(socket, _params) do
    socket
  end

  defp prepare_dashboard(socket, dashboard) do
    socket
    |> import_filters(dashboard.filters)
    |> trigger_indicators_visualizations_events(dashboard.indicators_visualizations)
    |> LiveView.assign(:dashboard, dashboard)
  end

  defp import_filters(socket, filters) do
    filters = Map.new(Enum.map(filters, &parse_filter/1))
    LiveView.assign(socket, :filters, filters)
  end

  defp parse_filter(%{filter_id: filter_id, value: value}) do
    case filter_id do
      "births_child_mass" -> {:child_mass, parse_value(:atom, value)}
      "births_child_masses" -> {:child_masses, parse_value({:list, :atom}, value)}
      "births_child_sex" -> {:child_sex, parse_value(:atom, value)}
      "births_deliveries" -> {:birth_deliveries, parse_value({:list, :atom}, value)}
      "births_delivery" -> {:birth_delivery, parse_value(:atom, value)}
      "births_gestation_duration" -> {:gestation_duration, parse_value(:atom, value)}
      "births_gestation_durations" -> {:gestation_durations, parse_value({:list, :atom}, value)}
      "births_location" -> {:birth_location, parse_value(:atom, value)}
      "births_locations" -> {:birth_locations, parse_value({:list, :atom}, value)}
      "births_mother_age" -> {:mother_age, parse_value(:atom, value)}
      "births_mother_ages" -> {:mother_ages, parse_value({:list, :atom}, value)}
      "births_prenatal_consultation" -> {:prenatal_consultation, parse_value(:atom, value)}
      "births_prenatal_consultations" -> {:prenatal_consultations, parse_value({:list, :atom}, value)}
      "geo_cities" -> {:cities_ids, parse_value({:list, :integer}, value)}
      "geo_city" -> {:city_id, parse_value(:integer, value)}
      "geo_country" -> {:country_id, parse_value(:integer, value)}
      "geo_health_region" -> {:health_region_id, parse_value(:integer, value)}
      "geo_health_regions" -> {:health_regions_ids, parse_value({:list, :integer}, value)}
      "geo_region" -> {:region_id, parse_value(:integer, value)}
      "geo_regions" -> {:regions_ids, parse_value({:list, :integer}, value)}
      "geo_state" -> {:state_id, parse_value(:integer, value)}
      "geo_states" -> {:states_ids, parse_value({:list, :integer}, value)}
      "person_age_group" -> {:age_group, parse_value(:atom, value)}
      "person_age_groups" -> {:age_groups, parse_value({:list, :atom}, value)}
      "person_sex" -> {:sex, parse_value(:atom, value)}
      "time_date_period" -> {:date_period, parse_value({:list, :date}, value)}
      "time_date" -> {:date, parse_value(:date, value)}
      "time_week_period" -> {:week_period, parse_value({:list, :integer}, value)}
      "time_week" -> {:week, parse_value(:integer, value)}
      "time_year_period" -> {:year_period, parse_value({:list, :integer}, value)}
      "time_year" -> {:year, parse_value(:integer, value)}
    end
  end

  defp parse_value(type, value) do
    case type do
      :atom -> String.to_existing_atom(value)
      :date -> Date.from_iso8601!(value)
      :integer -> String.to_integer(value)
      {:list, type} -> Enum.map(String.split(value, ","), &parse_value(type, &1))
    end
  end

  defp trigger_indicators_visualizations_events(socket, indicators_visualizations) do
    process = self()
    filters = socket.assigns.filters

    Enum.each(indicators_visualizations, &send(process, {:fetch_indicator_visualization_data, &1, filters}))

    socket
  end
end
