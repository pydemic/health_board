defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayHospitalizationFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_deaths: %{confirmed: deaths}, day_hospitalizations: %{confirmed: hospitalizations}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        hospitalization_fatality_rate: Math.hospitalization_fatality_rate(deaths, hospitalizations),
        deaths: deaths,
        hospitalizations: hospitalizations
      },
      last_record_date: data.last_record_date
    }
  end
end
