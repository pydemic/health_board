defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDayCitiesDeaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_cities_covid_reports
    |> Enum.sort(&(&1.deaths >= &2.deaths))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, deaths: &1.deaths})
    |> wrap_result(data)
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "Município"
      },
      result: %{
        ranking: ranking
      }
    }
  end
end
