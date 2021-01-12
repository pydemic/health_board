defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicStatesIncidenceRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_states_population

    data.states_covid_reports
    |> Enum.map(&fetch_covid_reports_rate(&1, populations))
    |> Enum.sort(&(&1.incidence_rate >= &2.incidence_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_covid_reports_rate(%{incidence: incidence, location_id: location_id} = covid_reports, populations) do
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))
    %{name: covid_reports.location_name, incidence_rate: Math.incidence_rate(incidence, population)}
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "UF"
      },
      result: %{
        ranking: ranking
      }
    }
  end
end
