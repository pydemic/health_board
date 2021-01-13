defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDayStatesIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_states_covid_reports
    |> Enum.sort(&(&1.incidence >= &2.incidence))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, incidence: &1.incidence})
    |> wrap_result(data)
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "UF"
      },
      result: %{
        ranking: ranking
      },
      last_record_date: data.last_record_date
    }
  end
end
