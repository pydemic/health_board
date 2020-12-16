defmodule HealthBoardWeb.DashboardLive.CardData.CrudeBirthRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{year_births: %{total: births}, year_population: %{total: population}} = data
    rate = if population > 0, do: births * 100 / population, else: 0.0

    %{
      filters: %{
        year: data.year,
        location: data.location_name
      },
      result: %{rate: rate, births: births, population: population}
    }
  end
end
