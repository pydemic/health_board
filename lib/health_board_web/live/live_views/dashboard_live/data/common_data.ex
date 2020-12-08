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
      %{city: id} -> Locations.get_by(context: Locations.context!(:city), id: id)
      %{health_region: id} -> Locations.get_by(context: Locations.context!(:health_region), id: id)
      %{state: id} -> Locations.get_by(context: Locations.context!(:state), id: id)
      %{region: id} -> Locations.get_by(context: Locations.context!(:region), id: id)
      %{country: id} -> Locations.get_by(context: Locations.context!(:country), id: id)
      _filters -> Locations.get_by(default)
    end
  end

  @spec children_locations(Locations.t()) :: list(Locations.t())
  def children_locations(%{id: id, context: context}) do
    case context do
      0 -> Locations.list_by(parents_ids: @regions)
      _context -> Locations.list_by(parent_id: id)
    end
  end

  @spec locations(map, keyword) :: list(Locations.t())
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def locations(filters, default \\ @default_locations) do
    case filters do
      %{city: id} -> Locations.list_siblings_by(id)
      %{cities: ids} -> Locations.list_by(context: Locations.context!(:city), ids: ids)
      %{health_region: id} -> Locations.list_by(context: Locations.context!(:city), parent_id: id)
      %{health_regions: ids} -> Locations.list_by(context: Locations.context!(:health_region), ids: ids)
      %{state: id} -> Locations.list_by(context: Locations.context!(:health_region), parent_id: id)
      %{states: ids} -> Locations.list_by(context: Locations.context!(:state), ids: ids)
      %{region: id} -> Locations.list_by(context: Locations.context!(:state), parent_id: id)
      %{regions: id} -> Locations.list_by(context: Locations.context!(:region), ids: id)
      %{country: _id} -> Locations.list_by(context: Locations.context!(:state), parents_ids: @regions)
      _filters -> Locations.list_by(default)
    end
  end

  @spec fetch_week(map, integer) :: map
  def fetch_week(filters, default \\ @default_week) do
    Map.get(filters, :week, default)
  end

  @spec fetch_week_period(map, {integer, integer}) :: {integer, integer}
  def fetch_week_period(filters, default \\ @default_week_period) do
    {from_default, to_default} = default
    {Map.get(filters, :from_week, from_default), Map.get(filters, :to_week, to_default)}
  end

  @spec fetch_year(map, integer) :: integer
  def fetch_year(filters, default \\ @default_year) do
    Map.get(filters, :year, default)
  end

  @spec fetch_year_period(map, {integer, integer}) :: {integer, integer}
  def fetch_year_period(filters, default \\ @default_year_period) do
    {from_default, to_default} = default
    {Map.get(filters, :from_year, from_default), Map.get(filters, :to_year, to_default)}
  end
end
