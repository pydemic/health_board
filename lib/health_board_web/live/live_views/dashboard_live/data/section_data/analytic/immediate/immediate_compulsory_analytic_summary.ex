defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticSummary do
  @dashboard_data_keys [
    :location,
    :yearly_deaths,
    :yearly_morbidities,
    :yearly_populations
  ]

  @spec fetch(map()) :: map()
  def fetch(%{data: data} = section_data) do
    Map.put(section_data, :data, Map.take(data, @dashboard_data_keys))
  end
end