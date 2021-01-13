defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicHospitalizations do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{hospitalizations: data.hospitalizations.confirmed},
      last_record_date: data.last_record_date
    }
  end
end
