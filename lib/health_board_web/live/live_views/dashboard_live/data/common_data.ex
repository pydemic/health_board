defmodule HealthBoardWeb.DashboardLive.CommonData do
  alias HealthBoard.Contexts.Geo.Locations

  @brazil_id 76

  @country Locations.context!(:country)
  @region Locations.context!(:region)
  @state Locations.context!(:state)
  @health_region Locations.context!(:health_region)
  @city Locations.context!(:city)

  @default_location [context: @country, id: @brazil_id]

  @default_week 1
  @default_week_period {1, 53}

  @default_year 2020
  @default_year_period {2000, 2020}

  @spec location(map, keyword) :: Location.t()
  def location(filters, default \\ @default_location) do
    case filters do
      %{city: id} -> Locations.get_by(context: @city, id: id)
      %{health_region: id} -> Locations.get_by(context: @health_region, id: id)
      %{state: id} -> Locations.get_by(context: @state, id: id)
      %{region: id} -> Locations.get_by(context: @region, id: id)
      %{country: id} -> Locations.get_by(context: @country, id: id)
      _filters -> Locations.get_by(default)
    end
  end

  @spec locations(map, keyword) :: list(Locations.t())
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def locations(filters, opts \\ []) do
    params = Keyword.get(opts, :extra_params, [])

    case filters do
      %{city: id} ->
        Locations.list_siblings(id)

      %{cities: ids} ->
        Locations.list_by(params ++ [context: @city, ids: ids])

      %{health_region: id} ->
        Locations.list_children(id, @city)

      %{health_regions: ids} ->
        Locations.list_by(params ++ [context: @health_region, ids: ids])

      %{state: id} ->
        Locations.list_children(id, @health_region)

      %{states: ids} ->
        Locations.list_by(params ++ [context: @state, ids: ids])

      %{region: id} ->
        Locations.list_children(id, @state)

      %{regions: id} ->
        Locations.list_by(params ++ [context: @region, ids: id])

      %{country: id} ->
        Locations.list_children(id, @region)

      _filters ->
        Locations.list_children(
          Keyword.get(opts, :default_id, @brazil_id),
          Keyword.get(opts, :default_context, @state)
        )
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
