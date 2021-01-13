defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicHospitalizationRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{hospitalizations: %{confirmed: hospitalizations}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        hospitalization_rate: Math.hospitalization_rate(hospitalizations, population),
        hospitalizations: hospitalizations,
        population: population
      },
      last_record_date: data.last_record_date
    }
  end
end
