defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicDeathRateMap do
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize, Math}

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, %{year_cities_population: populations} = data) do
    cities_covid_reports = Enum.map(data.cities_covid_reports, &fetch_death_rate(&1, populations))
    ranges = fetch_ranges(cities_covid_reports)

    Process.send_after(
      pid,
      {
        :exec_and_emit,
        &do_fetch/1,
        Map.merge(data, %{cities_covid_reports: cities_covid_reports, ranges: ranges}),
        {:map, :choropleth}
      },
      1_000
    )

    %{labels: ranges}
  end

  defp fetch_death_rate(%{deaths: deaths, location_id: location_id} = covid_report, populations) do
    population = Enum.find_value(populations, 0, &if(&1.location_id == location_id, do: &1.total))
    Map.put(covid_report, :death_rate, Math.death_rate(deaths, population))
  end

  defp fetch_ranges(rates) do
    rates
    |> Enum.map(& &1.death_rate)
    |> Choropleth.weighted_distribution()
  end

  defp do_fetch(data) do
    %{
      section_card_id: section_card_id,
      location: location,
      cities_covid_reports: cities_covid_reports,
      ranges: ranges
    } = data

    cities_covid_reports
    |> Enum.map(&fetch_covid_reports(&1, ranges))
    |> wrap_result(section_card_id, location)
  end

  defp fetch_covid_reports(%{location_id: id, location_name: label, death_rate: death_rate}, ranges) do
    group = Choropleth.group(ranges, death_rate)

    %{
      id: id,
      label: label,
      value: Humanize.number(death_rate),
      color: Choropleth.group_color(group),
      group: group
    }
  end

  defp wrap_result(data, id, location) do
    %{
      id: id,
      label: "Taxa de mortalidade",
      data: data,
      location: location,
      children_context: :city
    }
  end
end
