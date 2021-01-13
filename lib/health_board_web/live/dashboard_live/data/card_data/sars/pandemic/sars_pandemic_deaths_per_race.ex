defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicDeathsPerRace do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :vertical_bar}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      },
      last_record_date: data.last_record_date
    }
  end

  @labels [
    "Branca",
    "Preta",
    "Amarela",
    "Parda",
    "Indígena",
    "Ignorada"
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
    %{deaths: deaths} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "Óbitos",
      data: Enum.map(@fields, &Map.get(deaths, &1, 0))
    }
  end
end
