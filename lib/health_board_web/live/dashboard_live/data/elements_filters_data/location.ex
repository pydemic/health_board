defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData.Location do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.Helpers.Humanize

  @spec location(map) :: map
  def location(params) do
    location = location_value(params["location"], params["default"])
    %{name: "location", value: location, verbose_value: Humanize.location(location), options: location_options()}
  end

  defp location_value(location_id, default) do
    if is_nil(location_id) do
      if is_nil(default) do
        get_location(76)
      else
        get_location(default)
      end
    else
      get_location(location_id) || location_value(nil, default)
    end
  end

  defp location_options do
    %{
      locations: ElementsData.database_data(Locations, :list_by, [[]])
    }
  end

  defp get_location(id) do
    ElementsData.database_data(Locations, :get_by, [[id: id]])
  end
end
