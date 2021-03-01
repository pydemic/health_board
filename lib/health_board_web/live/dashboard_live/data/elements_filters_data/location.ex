defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData.Location do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.Helpers.Humanize

  @spec location(map) :: map
  def location(params) do
    location = location_value(params["location"], params["default"])

    %{value: location, verbose_value: Humanize.location(location), options: location_options()}
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
      locations:
        Locations
        |> ElementsData.apply_and_cache(:list_by, [[order_by: [asc: :name]]])
        |> Enum.map(&format_option/1)
    }
  end

  defp format_option(%{id: id, verbose_name: verbose_name}) do
    query_name =
      verbose_name
      |> String.downcase()
      |> :unicode.characters_to_nfd_binary()
      |> String.replace(~r/[^a-z0-9\s]/u, "")

    {verbose_name, {query_name, id}}
  end

  defp get_location(id) do
    ElementsData.apply_and_cache(Locations, :get_by, [[id: id, preload: :parents]])
  end
end
