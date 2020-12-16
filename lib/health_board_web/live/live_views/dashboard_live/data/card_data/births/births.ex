defmodule HealthBoardWeb.DashboardLive.CardData.Births do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{year_births: %{total: births}} = data

    %{
      filters: %{
        year: data.year,
        location: data.location_name
      },
      result: %{births: births}
    }
  end
end
