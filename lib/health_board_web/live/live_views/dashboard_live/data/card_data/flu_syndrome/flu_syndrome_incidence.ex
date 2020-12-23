defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{incidence: data.day_cases.confirmed}
    }
  end
end
