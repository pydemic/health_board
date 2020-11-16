defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerChildMass do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Births

  @filter_key "births_child_masses"

  @default_fields [
    :child_mass_500_or_less,
    :child_mass_500_999,
    :child_mass_1000_1499,
    :child_mass_1500_2499,
    :child_mass_2500_2999,
    :child_mass_3000_3999,
    :child_mass_4000_or_more,
    :ignored_child_mass
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year(&@indicator.subtract_year_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@indicator.get_births!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :vertical_bar)
  end

  defp get_labels(%{data: %{fields: fields}}) do
    for field <- fields, into: %{}, do: get_label(field)
  end

  defp get_label(field) do
    case field do
      :child_mass_500_or_less -> {field, "Menos de 500g"}
      :child_mass_500_999 -> {field, "Entre 500g e 999g"}
      :child_mass_1000_1499 -> {field, "Entre 1000g e 1499g"}
      :child_mass_1500_2499 -> {field, "Entre 1500g e 2499g"}
      :child_mass_2500_2999 -> {field, "Entre 2500g e 2999g"}
      :child_mass_3000_3999 -> {field, "Entre 3000g e 3999g"}
      :child_mass_4000_or_more -> {field, "Mais de 4000g"}
      :ignored_child_mass -> {field, "Ignorado"}
    end
  end

  defp get_result(%{data: %{fields: fields}, extra: %{births: births}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(births, field, 0)
      }
    end)
  end
end
