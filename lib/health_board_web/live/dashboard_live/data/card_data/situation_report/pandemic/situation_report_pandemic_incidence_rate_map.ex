defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicIncidenceRateMap do
  alias HealthBoardWeb.Helpers.{Choropleth, Humanize, Math}

  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, %{year_cities_population: populations} = data) do
    cities_covid_reports = Enum.map(data.cities_covid_reports, &fetch_incidence_rate(&1, populations))
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

  defp fetch_incidence_rate(%{incidence: incidence, location_id: location_id} = covid_report, populations) do
    population = Enum.find_value(populations, 0, &if(&1.location_id == location_id, do: &1.total))
    Map.put(covid_report, :incidence_rate, Math.incidence_rate(incidence, population))
  end

  defp fetch_ranges(rates) do
    rates
    |> Enum.map(& &1.incidence_rate)
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

  defp fetch_covid_reports(%{location_id: id, location_name: label, incidence_rate: incidence_rate}, ranges) do
    group = Choropleth.group(ranges, incidence_rate)

    %{
      id: id,
      label: label,
      value: Humanize.number(incidence_rate),
      color: Choropleth.group_color(group),
      group: group
    }
  end

  defp wrap_result(data, id, location) do
    %{
      id: id,
      label: "Taxa de incidência",
      data: data,
      location: location,
      children_context: :city
    }
  end
end
