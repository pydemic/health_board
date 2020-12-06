defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticRegion do
  @dashboard_data_keys [
    :locations,
    :locations_year_deaths,
    :locations_year_morbidities,
    :locations_year_populations
  ]

  @spec fetch(map()) :: map()
  def fetch(%{data: data} = section_data) do
    Map.put(section_data, :data, Map.take(data, @dashboard_data_keys))
  end
end
