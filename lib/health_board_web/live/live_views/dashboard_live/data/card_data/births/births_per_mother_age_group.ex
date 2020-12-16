defmodule HealthBoardWeb.DashboardLive.CardData.BirthsPerMotherAgeGroup do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :horizontal_bar}}, 1_000)

    %{
      filters: %{
        year: data.births_year,
        location: data.location_name
      }
    }
  end

  @labels [
    "10 anos ou menos",
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
    "60 anos ou mais",
    "Ignorado"
  ]

  @fields [
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
    :ignored_gestation_duration
  ]

  defp do_fetch(data) do
    %{year_births: births} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "Nascidos Vivos",
      data: Enum.map(@fields, &Map.get(births, &1, 0))
    }
  end
end
