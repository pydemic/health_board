defmodule HealthBoardWeb.DashboardLive.CardData.GenderRatio do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{year_population: %{female: female, male: male}} = data
    ratio = if female > 0, do: male * 100 / female, else: 0.0

    %{
      filters: %{
        year: data.year,
        location: data.location_name
      },
      result: %{ratio: ratio, female: female, male: male}
    }
  end
end
