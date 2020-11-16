defmodule HealthBoardWeb.DashboardLive.IndicatorsData.CommonData do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @brazil_id 76
  @default_location [level: Locations.country_level(), id: @brazil_id]
  @default_locations [level: Locations.region_level(), parent_id: @brazil_id]
  @default_year 2020
  @default_year_period [2000, 2020]

  @spec fetch_location(IndicatorsData.t(), keyword()) :: IndicatorsData.t()
  def fetch_location(%{filters: filters} = indicators_data, default \\ @default_location) do
    indicators_data
    |> IndicatorsData.put(:extra, :location, get_location(filters, default))
    |> IndicatorsData.exec_and_put(:modifiers, :location_id, &Map.get(&1.extra.location, :id))
  end

  defp get_location(filters, default) do
    case filters do
      %{"geo_city" => id} -> Locations.get_by(level: Locations.city_level(), id: id)
      %{"geo_health_region" => id} -> Locations.get_by(level: Locations.health_region_level(), id: id)
      %{"geo_state" => id} -> Locations.get_by(level: Locations.state_level(), id: id)
      %{"geo_region" => id} -> Locations.get_by(level: Locations.region_level(), id: id)
      %{"geo_country" => id} -> Locations.get_by(level: Locations.country_level(), id: id)
      _filters -> Locations.get_by(default)
    end
  end

  @spec fetch_locations(IndicatorsData.t(), keyword()) :: IndicatorsData.t()
  def fetch_locations(%{filters: filters} = indicators_data, default \\ @default_locations) do
    indicators_data
    |> IndicatorsData.put(:extra, :locations, get_locations(filters, default))
    |> IndicatorsData.exec_and_put(
      :modifiers,
      :locations_ids,
      &Enum.map(&1.extra.locations, fn %{id: id} -> id end)
    )
  end

  defp get_locations(filters, default) do
    case filters do
      %{"geo_city" => id} -> Locations.list_siblings_by(id)
      %{"geo_cities" => ids} -> Locations.list_by(level: Locations.city_level(), ids: ids)
      %{"geo_health_region" => id} -> Locations.list_by(level: Locations.city_level(), parent_id: id)
      %{"geo_health_regions" => ids} -> Locations.list_by(level: Locations.health_region_level(), ids: ids)
      %{"geo_state" => id} -> Locations.list_by(level: Locations.health_region_level(), parent_id: id)
      %{"geo_states" => ids} -> Locations.list_by(level: Locations.state_level(), ids: ids)
      %{"geo_region" => id} -> Locations.list_by(level: Locations.state_level(), parent_id: id)
      %{"geo_regions" => id} -> Locations.list_by(level: Locations.region_level(), ids: id)
      %{"geo_country" => id} -> Locations.list_by(level: Locations.region_level(), parent_id: id)
      _filters -> Locations.list_by(default)
    end
  end

  @spec fetch_year(IndicatorsData.t(), integer() | (integer() | nil -> integer())) :: IndicatorsData.t()
  def fetch_year(indicators_data, default \\ @default_year) do
    indicators_data
    |> IndicatorsData.exec_and_put(:extra, :year, &get_year(&1.filters, default))
    |> IndicatorsData.exec_and_put(:modifiers, :year, & &1.extra.year)
  end

  defp get_year(filters, default) do
    year = Map.get(filters, "time_year")

    if is_function(default) do
      default.(year)
    else
      year || default
    end
  end

  @spec fetch_year_period(IndicatorsData.t(), list(integer()) | (list(integer()) | nil -> list(integer()))) ::
          IndicatorsData.t()
  def fetch_year_period(indicators_data, default \\ @default_year_period) do
    indicators_data
    |> IndicatorsData.exec_and_put(:extra, :year_period, &get_year_period(&1.filters, default))
    |> IndicatorsData.exec_and_put(:modifiers, :year_period, & &1.extra.year_period)
  end

  defp get_year_period(filters, default) do
    year_period = Map.get(filters, "time_year_period")

    if is_function(default) do
      default.(year_period)
    else
      year_period || default
    end
  end
end
