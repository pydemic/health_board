defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportDayIncidenceRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_covid_reports: %{cases: incidence}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        incidence_rate: Math.incidence_rate(incidence, population),
        incidence: incidence,
        population: population
      },
      last_record_date: data.last_record_date
    }
  end
end
