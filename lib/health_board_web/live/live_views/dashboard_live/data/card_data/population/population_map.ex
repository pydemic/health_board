defmodule HealthBoardWeb.DashboardLive.CardData.PopulationMap do
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize}

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    ranges = fetch_ranges(data.year_locations_population)

    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, Map.put(data, :ranges, ranges), {:map, :choropleth}}, 1_000)

    %{
      filters: %{
        year: data.year,
        locations: data.locations_names
      },
      labels: ranges
    }
  end

  defp fetch_ranges(populations) do
    populations
    |> Enum.map(& &1.total)
    |> Choropleth.quartile(type: :integer)
  end

  defp do_fetch(data) do
    %{
      section_card_id: section_card_id,
      location: location,
      locations: locations,
      year_locations_population: populations,
      ranges: ranges
    } = data

    locations
    |> Enum.map(&fetch_population(&1, populations, ranges))
    |> wrap_result(section_card_id, location)
  end

  defp fetch_population(%{id: id, name: label}, populations, ranges) do
    population = Enum.find_value(populations, 0, &if(&1.location_id == id, do: &1.total))

    %{id: id, label: label, value: Humanize.number(population), color: Choropleth.group_color(ranges, population)}
  end

  defp wrap_result(data, id, location) do
    %{
      id: id,
      label: "População residente",
      data: data,
      location: location
    }
  end
end
