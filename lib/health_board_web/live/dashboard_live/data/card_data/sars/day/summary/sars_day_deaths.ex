defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayDeaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{deaths: data.day_deaths.confirmed}
    }
  end
end
