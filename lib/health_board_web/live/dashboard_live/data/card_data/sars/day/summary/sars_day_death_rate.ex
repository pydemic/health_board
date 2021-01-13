defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayDeathRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_deaths: %{confirmed: deaths}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        death_rate: Math.death_rate(deaths, population),
        deaths: deaths,
        population: population
      },
      last_record_date: data.last_record_date
    }
  end
end
