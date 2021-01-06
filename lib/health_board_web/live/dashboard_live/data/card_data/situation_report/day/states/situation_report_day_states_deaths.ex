defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDayStatesDeaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_states_covid_reports
    |> Enum.sort(&(&1.deaths >= &2.deaths))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, deaths: &1.deaths})
    |> wrap_result(data)
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
