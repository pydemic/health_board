defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicStatesDeathRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_states_population

    data.states_covid_reports
    |> Enum.map(&fetch_death_rate(&1, populations))
    |> Enum.sort(&(&1.death_rate >= &2.death_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_death_rate(covid_reports, populations) do
    %{deaths: deaths, location_id: location_id} = covid_reports
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))

    %{
      name: covid_reports.location_name,
      death_rate: Math.death_rate(deaths, population)
    }
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "Estado"
      },
      result: %{
        ranking: ranking
      }
    }
  end
end
