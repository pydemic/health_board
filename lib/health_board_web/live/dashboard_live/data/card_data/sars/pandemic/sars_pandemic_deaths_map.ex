defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicDeathsMap do
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize}

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    ranges = fetch_ranges(data.cities_deaths)
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, Map.put(data, :ranges, ranges), {:map, :choropleth}}, 1_000)
    %{labels: ranges}
  end

  defp fetch_ranges(cities_deaths) do
    cities_deaths
    |> Enum.map(& &1.confirmed)
    |> Choropleth.quartile()
  end

  defp do_fetch(data) do
    %{
      section_card_id: section_card_id,
      location: location,
      cities_deaths: cities_deaths,
      ranges: ranges
    } = data

    cities_deaths
    |> Enum.map(&fetch_deaths(&1, ranges))
    |> wrap_result(section_card_id, location)
  end

  defp fetch_deaths(%{location_id: id, location_name: label, confirmed: confirmed}, ranges) do
    %{
      id: id,
      label: label,
      value: Humanize.number(confirmed),
      color: Choropleth.group_color(ranges, confirmed)
    }
  end

  defp wrap_result(data, id, location) do
    %{
      id: id,
      label: "Óbitos",
      data: data,
      location: location,
      children_context: :city
    }
  end
end
