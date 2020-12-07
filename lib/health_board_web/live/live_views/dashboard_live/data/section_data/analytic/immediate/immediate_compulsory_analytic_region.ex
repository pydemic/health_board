defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateCompulsoryAnalyticRegion do
  @data_keys ~w[locations locations_year_deaths locations_year_morbidities locations_year_populations]a
  @filter_keys ~w[morbidity_contexts year]a

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
