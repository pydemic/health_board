defmodule HealthBoardWeb.DashboardLive.CommonData do
  alias HealthBoard.Contexts.Geo.Locations

  @brazil_id 76
  @regions [1, 2, 3, 4, 5]
  @default_location [level: Locations.context!(:country), id: @brazil_id]
  @default_locations [level: Locations.context!(:state), parents_ids: @regions]
  @default_week 1
  @default_week_period {1, 53}
  @default_year 2020
  @default_year_period {2000, 2020}

  @spec location(map, keyword) :: Location.t()
  def location(filters, default \\ @default_location) do
    case filters do
      %{"geo_city" => id} -> Locations.get_by(context: Locations.context!(:city), id: id)
      %{"geo_health_region" => id} -> Locations.get_by(context: Locations.context!(:health_region), id: id)
      %{"geo_state" => id} -> Locations.get_by(context: Locations.context!(:state), id: id)
      %{"geo_region" => id} -> Locations.get_by(context: Locations.context!(:region), id: id)
      %{"geo_country" => id} -> Locations.get_by(context: Locations.context!(:country), id: id)
      _filters -> Locations.get_by(default)
    end
  end

  @spec fetch_locations(map, keyword) :: list(Locations.t())
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def fetch_locations(filters, default \\ @default_locations) do
    case filters do
      %{"geo_city" => id} -> Locations.list_siblings_by(id)
      %{"geo_cities" => ids} -> Locations.list_by(context: Locations.context!(:city), ids: ids)
      %{"geo_health_region" => id} -> Locations.list_by(context: Locations.context!(:city), parent_id: id)
      %{"geo_health_regions" => ids} -> Locations.list_by(context: Locations.context!(:health_region), ids: ids)
      %{"geo_state" => id} -> Locations.list_by(context: Locations.context!(:health_region), parent_id: id)
      %{"geo_states" => ids} -> Locations.list_by(context: Locations.context!(:state), ids: ids)
      %{"geo_region" => id} -> Locations.list_by(context: Locations.context!(:state), parent_id: id)
      %{"geo_regions" => id} -> Locations.list_by(context: Locations.context!(:region), ids: id)
      %{"geo_country" => _id} -> Locations.list_by(context: Locations.context!(:state), parents_ids: @regions)
      _filters -> Locations.list_by(default)
    end
  end

  @spec fetch_week(map, integer) :: map
  def fetch_week(filters, default \\ @default_week) do
    Map.get(filters, "time_week", default)
  end

  @spec fetch_week_period(map, {integer, integer}) :: {integer, integer}
  def fetch_week_period(filters, default \\ @default_week_period) do
    {from_default, to_default} = default
    {Map.get(filters, "time_from_week", from_default), Map.get(filters, "time_to_week", to_default)}
  end

  @spec fetch_year(map, integer) :: integer
  def fetch_year(filters, default \\ @default_year) do
    Map.get(filters, "time_year", default)
  end

  @spec fetch_year_period(map, {integer, integer}) :: {integer, integer}
  def fetch_year_period(filters, default \\ @default_year_period) do
    {from_default, to_default} = default
    {Map.get(filters, "time_from_year", from_default), Map.get(filters, "time_to_year", to_default)}
  end
end
