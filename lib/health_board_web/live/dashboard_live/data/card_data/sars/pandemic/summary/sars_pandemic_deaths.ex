defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicDeaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{deaths: data.deaths.confirmed}
    }
  end
end
