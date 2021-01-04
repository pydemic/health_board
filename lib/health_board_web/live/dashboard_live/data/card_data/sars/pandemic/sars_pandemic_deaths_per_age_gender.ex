defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicDeathsPerAgeGender do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :pyramid_bar}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      }
    }
  end

  @labels [
    "80 anos ou mais",
    "Entre 75 e 79 anos",
    "Entre 70 e 74 anos",
    "Entre 65 e 69 anos",
    "Entre 60 e 64 anos",
    "Entre 55 e 59 anos",
    "Entre 50 e 54 anos",
    "Entre 45 e 49 anos",
    "Entre 40 e 44 anos",
    "Entre 35 e 39 anos",
    "Entre 30 e 34 anos",
    "Entre 25 e 29 anos",
    "Entre 20 e 24 anos",
    "Entre 15 e 19 anos",
    "Entre 10 e 14 anos",
    "Entre 5 e 9 anos",
    "Entre 0 e 4 anos"
  ]

  @female_fields [
    :female_80_or_more,
    :female_75_79,
    :female_70_74,
    :female_65_69,
    :female_60_64,
    :female_55_59,
    :female_35_39,
    :female_50_54,
    :female_45_49,
    :female_40_44,
    :female_30_34,
    :female_25_29,
    :female_20_24,
    :female_15_19,
    :female_10_14,
    :female_5_9,
    :female_0_4
  ]

  @male_fields [
    :male_80_or_more,
    :male_75_79,
    :male_70_74,
    :male_65_69,
    :male_60_64,
    :male_55_59,
    :male_35_39,
    :male_50_54,
    :male_45_49,
    :male_40_44,
    :male_30_34,
    :male_25_29,
    :male_20_24,
    :male_15_19,
    :male_10_14,
    :male_5_9,
    :male_0_4
  ]

  defp do_fetch(data) do
    %{deaths: deaths} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      positive_label: "Feminino",
      positive_data: Enum.map(@female_fields, &Map.get(deaths, &1, 0)),
      negative_label: "Masculino",
      negative_data: Enum.map(@male_fields, &Map.get(deaths, &1, 0))
    }
  end
end
