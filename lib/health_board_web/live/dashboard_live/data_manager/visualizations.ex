defmodule HealthBoardWeb.DashboardLive.DataManager.Visualizations do
  alias HealthBoard.Contexts.Demographic

  @default_population_filters %{country_id: 76, year: 2020}
  @non_population_filters [:year_period]

  @spec fetch_population(map()) :: integer()
  def fetch_population(filters) do
    filters = Map.merge(@default_population_filters, Map.drop(filters, @non_population_filters))

    case filters do
      %{city_id: _} -> Demographic.CitiesPopulation.get_total_by(filters)
      %{health_region_id: _} -> Demographic.HealthRegionsPopulation.get_total_by(filters)
      %{state_id: _} -> Demographic.StatesPopulation.get_total_by(filters)
      %{region_id: _} -> Demographic.RegionsPopulation.get_total_by(filters)
      _ -> Demographic.CountriesPopulation.get_total_by(filters)
    end
  end

  @default_population_growth_filters %{country_id: 76, year_period: [2000, 2020]}
  @non_population_growth_filters [:year]

  @spec fetch_population_growth(map()) :: list(integer())
  def fetch_population_growth(filters) do
    filters = Map.merge(@default_population_growth_filters, Map.drop(filters, @non_population_growth_filters))

    case filters do
      %{city_id: _city_id} -> Demographic.CitiesPopulation.list_total_by(filters)
      %{health_region_id: _} -> Demographic.HealthRegionsPopulation.list_total_by(filters)
      %{state_id: _} -> Demographic.StatesPopulation.list_total_by(filters)
      %{region_id: _} -> Demographic.RegionsPopulation.list_total_by(filters)
      _ -> Demographic.CountriesPopulation.list_total_by(filters)
    end
  end

  @default_population_per_age_group_filters %{country_id: 76, year: 2020}
  @non_population_per_age_group_filters [:year_period]

  @spec fetch_population_per_age_group(map()) :: map()
  def fetch_population_per_age_group(filters) do
    filters =
      Map.merge(@default_population_per_age_group_filters, Map.drop(filters, @non_population_per_age_group_filters))

    case filters do
      %{city_id: _city_id} -> Demographic.CitiesPopulation.get_by(filters)
      %{health_region_id: _} -> Demographic.HealthRegionsPopulation.get_by(filters)
      %{state_id: _} -> Demographic.StatesPopulation.get_by(filters)
      %{region_id: _} -> Demographic.RegionsPopulation.get_by(filters)
      _ -> Demographic.CountriesPopulation.get_by(filters)
    end
  end

  @default_population_per_sex_filters %{country_id: 76, year: 2020}
  @non_population_per_sex_filters [:year_period]

  @spec fetch_population_per_sex(map()) :: map()
  def fetch_population_per_sex(filters) do
    filters = Map.merge(@default_population_per_sex_filters, Map.drop(filters, @non_population_per_sex_filters))

    case filters do
      %{city_id: _city_id} -> Demographic.CitiesPopulation.get_by(filters)
      %{health_region_id: _} -> Demographic.HealthRegionsPopulation.get_by(filters)
      %{state_id: _} -> Demographic.StatesPopulation.get_by(filters)
      %{region_id: _} -> Demographic.RegionsPopulation.get_by(filters)
      _ -> Demographic.CountriesPopulation.get_by(filters)
    end
  end
end
