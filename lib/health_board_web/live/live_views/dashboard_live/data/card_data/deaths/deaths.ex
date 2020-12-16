defmodule HealthBoardWeb.DashboardLive.CardData.Deaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        year: data.year,
        location: data.location_name,
        morbidity_context: data.morbidity_name
      },
      result: %{cases: data.year_deaths.total}
    }
  end
end
