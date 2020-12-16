defmodule HealthBoardWeb.DashboardLive.CardData.Population do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        year: data.year,
        location: data.location_name
      },
      result: %{population: data.year_population.total}
    }
  end
end
