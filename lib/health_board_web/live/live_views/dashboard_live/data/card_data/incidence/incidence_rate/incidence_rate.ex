defmodule HealthBoardWeb.DashboardLive.CardData.IncidenceRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{year_morbidity: %{total: cases}, year_population: %{total: population}} = data

    rate = if population > 0, do: cases * 100_000 / population, else: 0.0

    %{
      filters: %{
        year: data.year,
        location: data.location_name,
        morbidity_context: data.morbidity_name
      },
      result: %{rate: rate}
    }
  end
end
