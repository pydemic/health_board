defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDayCitiesFatalityRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_cities_covid_reports
    |> Enum.sort(&(&1.fatality_rate >= &2.fatality_rate))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, fatality_rate: &1.fatality_rate})
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
      },
      last_record_date: data.last_record_date
    }
  end
end
