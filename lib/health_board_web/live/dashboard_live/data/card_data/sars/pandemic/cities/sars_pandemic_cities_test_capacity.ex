defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicCitiesTestCapacity do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.cities_incidence
    |> Enum.sort(&(&1.test_capacity >= &2.test_capacity))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, test_capacity: &1.test_capacity})
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
