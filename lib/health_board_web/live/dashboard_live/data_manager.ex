defmodule HealthBoardWeb.DashboardLive.DataManager do
  import Phoenix.LiveView, only: [assign: 3, redirect: 2]
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.DataManager.Visualizations
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @spec initial_data(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def initial_data(socket, %{"dashboard_id" => id}) do
    case Info.Dashboards.get(id, preload_all?: true) do
      {:ok, dashboard} -> prepare_dashboard(socket, dashboard)
      _not_found -> redirect(socket, to: Routes.home_path(socket, :index))
    end
  end

  @spec update(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def update(socket, _params) do
    socket
  end

  defp prepare_dashboard(socket, dashboard) do
    socket
    |> import_filters(dashboard.filters)
    |> import_indicators_visualizations(dashboard.indicators_visualizations)
    |> assign(:dashboard, dashboard)
  end

  defp import_filters(socket, filters) do
    filters = Map.new(Enum.map(filters, &parse_filter/1))
    assign(socket, :filters, filters)
  end

  defp parse_filter(%{filter_id: filter_id, value: value}) do
    case filter_id do
      "geo_cities" -> {:cities_ids, Enum.map(String.split(value, ","), &String.to_integer/1)}
      "geo_city" -> {:city_id, String.to_integer(value)}
      "geo_country" -> {:country_id, String.to_integer(value)}
      "geo_health_region" -> {:health_region_id, String.to_integer(value)}
      "geo_health_regions" -> {:health_regions_ids, Enum.map(String.split(value, ","), &String.to_integer/1)}
      "geo_region" -> {:region_id, String.to_integer(value)}
      "geo_regions" -> {:regions_ids, Enum.map(String.split(value, ","), &String.to_integer/1)}
      "geo_state" -> {:state_id, String.to_integer(value)}
      "geo_states" -> {:states_ids, Enum.map(String.split(value, ","), &String.to_integer/1)}
      "person_age_group" -> {:age_group, String.to_atom(value)}
      "person_age_groups" -> {:age_groups, Enum.map(String.split(value, ","), &String.to_atom/1)}
      "person_sex" -> {:sex, String.to_atom(value)}
      "time_year_period" -> {:year_period, Enum.map(String.split(value, ","), &String.to_integer/1)}
      "time_year" -> {:year, String.to_integer(value)}
    end
  end

  defp import_indicators_visualizations(socket, indicators_visualizations) do
    filters = socket.assigns.filters

    indicators_visualizations =
      indicators_visualizations
      |> Enum.map(&parse_indicator_visualization(&1, filters))
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    assign(socket, :indicators_visualizations, indicators_visualizations)
  end

  defp parse_indicator_visualization(%{indicator_visualization_id: id}, filters) do
    case id do
      "population" -> {:population, Visualizations.fetch_population(filters)}
      "population_growth" -> {:population_growth, Visualizations.fetch_population_growth(filters)}
      "population_per_age_group" -> {:population_per_age_group, Visualizations.fetch_population_per_age_group(filters)}
      "population_per_sex" -> {:population_per_sex, Visualizations.fetch_population_per_sex(filters)}
      # "population_map" -> {:population_map, Visualizations.fetch_population_map(filters)}
      # "population_ratio_map" -> {:population_ratio_map, Visualizations.fetch_population_ratio_map(filters)}
      # "population_ratio_table" -> {:population_ratio_table, Visualizations.fetch_population_ratio_table(filters)}
      # "population_table" -> {:population_table, Visualizations.fetch_population_table(filters)}
      _not_implemented -> nil
    end
  end
end
