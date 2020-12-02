defmodule HealthBoardWeb.DashboardLive.IndicatorsData.BirthsPerMotherAge do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.Births

  @filter_key "births_mother_ages"

  @default_fields [
    :mother_age_10_or_less,
    :mother_age_10_14,
    :mother_age_15_19,
    :mother_age_20_24,
    :mother_age_25_29,
    :mother_age_30_34,
    :mother_age_35_39,
    :mother_age_40_44,
    :mother_age_45_49,
    :mother_age_50_54,
    :mother_age_55_59,
    :mother_age_60_or_more,
    :ignored_mother_age
  ]

  @fields_labels %{
    mother_age_10_or_less: "10 anos ou menos",
    mother_age_10_14: "Entre 10 e 14 anos",
    mother_age_15_19: "Entre 15 e 19 anos",
    mother_age_20_24: "Entre 20 e 24 anos",
    mother_age_25_29: "Entre 25 e 29 anos",
    mother_age_30_34: "Entre 30 e 34 anos",
    mother_age_35_39: "Entre 35 e 39 anos",
    mother_age_40_44: "Entre 40 e 44 anos",
    mother_age_45_49: "Entre 45 e 49 anos",
    mother_age_50_54: "Entre 50 e 54 anos",
    mother_age_55_59: "Entre 55 e 59 anos",
    mother_age_60_or_more: "60 anos ou mais",
    ignored_mother_age: "Ignorado"
  }

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year(&@indicator.subtract_year_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &@indicator.get_births!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :labels, &Map.take(@fields_labels, &1.data.fields))
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :horizontal_bar)
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
