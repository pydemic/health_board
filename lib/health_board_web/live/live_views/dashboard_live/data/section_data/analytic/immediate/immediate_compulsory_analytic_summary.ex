defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticSummary do
  @data_keys ~w[data_periods yearly_deaths yearly_morbidities yearly_populations]a
  @filter_keys ~w[morbidity_context year]a

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
