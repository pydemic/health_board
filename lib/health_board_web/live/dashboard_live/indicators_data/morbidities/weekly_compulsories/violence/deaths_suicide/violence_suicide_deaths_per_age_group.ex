defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceSuicideDeathsPerAgeGroup do
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @indicator IndicatorsData.ViolenceSuicideDeaths

  @filter_key "person_age_groups"

  @default_fields [
    :age_0_4,
    :age_5_9,
    :age_10_14,
    :age_15_19,
    :age_20_24,
    :age_25_29,
    :age_30_34,
    :age_35_39,
    :age_40_44,
    :age_45_49,
    :age_50_54,
    :age_55_59,
    :age_60_64,
    :age_64_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  @fields_labels %{
    age_0_4: "Entre 0 e 4 anos",
    age_5_9: "Entre 5 e 9 anos",
    age_10_14: "Entre 10 e 14 anos",
    age_15_19: "Entre 15 e 19 anos",
    age_20_24: "Entre 20 e 24 anos",
    age_25_29: "Entre 25 e 29 anos",
    age_30_34: "Entre 30 e 34 anos",
    age_35_39: "Entre 35 e 39 anos",
    age_40_44: "Entre 40 e 44 anos",
    age_45_49: "Entre 45 e 49 anos",
    age_50_54: "Entre 50 e 54 anos",
    age_55_59: "Entre 55 e 59 anos",
    age_60_64: "Entre 60 e 64 anos",
    age_64_69: "Entre 65 e 69 anos",
    age_70_74: "Entre 70 e 74 anos",
    age_75_79: "Entre 75 e 79 anos",
    age_80_or_more: "80 anos ou mais"
  }

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year(2019)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :disease_context, &@indicator.get_disease_context/1)
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &@indicator.get_location_context/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &Map.get(&1.filters, @filter_key, @default_fields))
    |> IndicatorsData.exec_and_put(:extra, :cases, &@indicator.get_cases!/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &Map.take(@fields_labels, &1.data.fields))
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :horizontal_bar)
  end

  defp get_result(%{data: %{fields: fields}, extra: %{cases: cases}}) do
    Enum.map(fields, fn field ->
      %{
        field: field,
        value: Map.get(cases, field, 0)
      }
    end)
  end
end
