defmodule HealthBoardWeb.DashboardLive.SectionData.MorbiditySummary do
  @data_keys ~w[data_periods year_deaths year_morbidity year_population]a
  @filter_keys ~w[year location morbidity_context]a

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = section_data) do
    section_data
    |> Map.put(:data, Map.take(data, @data_keys))
    |> Map.put(:filters, Map.take(filters, @filter_keys))
  end
end
