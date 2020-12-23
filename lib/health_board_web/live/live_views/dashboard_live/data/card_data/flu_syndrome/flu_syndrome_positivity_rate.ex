defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePositivityRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{confirmed: confirmed, discarded: discarded} = data.day_cases
    total = confirmed + discarded

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        confirmed: confirmed,
        total: total,
        positivity_rate: calculate_positivity_rate(confirmed, total)
      }
    }
  end

  defp calculate_positivity_rate(confirmed, total) do
    if confirmed > 0 and total > 0 do
      confirmed * 100 / total
    else
      0.0
    end
  end
end
