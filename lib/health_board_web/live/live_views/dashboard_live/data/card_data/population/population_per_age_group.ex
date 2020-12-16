defmodule HealthBoardWeb.DashboardLive.CardData.PopulationPerAgeGroup do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :horizontal_bar}}, 1_000)

    %{
      filters: %{
        year: data.year,
        location: data.location_name
      }
    }
  end

  @labels [
    "Entre 0 e 4 anos",
    "Entre 5 e 9 anos",
    "Entre 10 e 14 anos",
    "Entre 15 e 19 anos",
    "Entre 20 e 24 anos",
    "Entre 25 e 29 anos",
    "Entre 30 e 34 anos",
    "Entre 35 e 39 anos",
    "Entre 40 e 44 anos",
    "Entre 45 e 49 anos",
    "Entre 50 e 54 anos",
    "Entre 55 e 59 anos",
    "Entre 60 e 64 anos",
    "Entre 65 e 69 anos",
    "Entre 70 e 74 anos",
    "Entre 75 e 79 anos",
    "80 anos ou mais"
  ]

  @fields [
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
    :age_65_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  defp do_fetch(data) do
    %{year_population: population} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "População residente",
      data: Enum.map(@fields, &Map.get(population, &1, 0))
    }
  end
end
