defmodule HealthBoardWeb.DashboardLive.CardData.DeathsPerRace do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :vertical_bar}}, 1_000)

    %{
      filters: %{
        year: data.year,
        location: data.location_name,
        morbidity_context: data.morbidity_name
      }
    }
  end

  @labels [
    "Branco",
    "Preto",
    "Amarelo",
    "Pardo",
    "Indígena",
    "Ignorado"
  ]

  @fields [
    :race_caucasian,
    :race_african,
    :race_asian,
    :race_brown,
    :race_native,
    :ignored_race
  ]

  defp do_fetch(data) do
    %{year_deaths: cases} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "Nascidos Vivos",
      data: Enum.map(@fields, &Map.get(cases, &1, 0))
    }
  end
end
