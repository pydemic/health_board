defmodule HealthBoardWeb.DashboardLive.CardData.IncidenceRateMap do
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize}

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    rates = fetch_rates(data)
    ranges = fetch_ranges(rates)

    Process.send_after(
      pid,
      {:exec_and_emit, &do_fetch/1, Map.merge(data, %{rates: rates, ranges: ranges}), {:map, :choropleth}},
      1_000
    )

    %{
      filters: %{
        year: data.year,
        locations: data.locations_names,
        morbidity_context: data.morbidity_name
      },
      labels: ranges
    }
  end

  defp fetch_rates(%{year_locations_morbidity: cases, year_locations_population: populations, locations: locations}) do
    Enum.map(locations, &fetch_rate(&1, cases, populations))
  end

  defp fetch_rate(%{id: id, name: label}, cases, populations) do
    cases = Enum.find_value(cases, 0, &if(&1.location_id == id, do: &1.total))
    population = Enum.find_value(populations, 0, &if(&1.location_id == id, do: &1.total))

    value = if cases > 0 and population > 0, do: cases * 100 / population, else: 0.0

    %{id: id, label: label, value: value}
  end

  defp fetch_ranges(rates) do
    rates
    |> Enum.map(& &1.value)
    |> Choropleth.quartile()
  end

  defp do_fetch(data) do
    %{
      section_card_id: section_card_id,
      location: location,
      ranges: ranges,
      rates: rates
    } = data

    rates
    |> Enum.map(&fetch_color(&1, ranges))
    |> wrap_result(section_card_id, location)
  end

  defp fetch_color(%{value: value} = rate, ranges) do
    Map.merge(rate, %{value: Humanize.number(value), color: Choropleth.group_color(ranges, value)})
  end

  defp wrap_result(data, id, location) do
    %{
      id: id,
      label: "Coeficiente de incidência",
      data: data,
      location: location
    }
  end
end
