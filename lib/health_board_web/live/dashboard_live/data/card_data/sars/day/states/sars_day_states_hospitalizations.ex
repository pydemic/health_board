defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayStatesHospitalizations do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_states_hospitalizations
    |> Enum.sort(&(&1.confirmed >= &2.confirmed))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, hospitalizations: &1.confirmed})
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
