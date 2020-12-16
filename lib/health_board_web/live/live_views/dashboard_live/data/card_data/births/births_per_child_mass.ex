defmodule HealthBoardWeb.DashboardLive.CardData.BirthsPerChildMass do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :vertical_bar}}, 1_000)

    %{
      filters: %{
        year: data.births_year,
        location: data.location_name
      }
    }
  end

  @labels [
    "Muito baixo peso",
    "Baixo peso",
    "Peso normal",
    "Alto peso",
    "Ignorado"
  ]

  defp do_fetch(data) do
    %{year_births: births} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "Nascidos Vivos",
      data: [
        births.child_mass_500_or_less + births.child_mass_500_999 + births.child_mass_1000_1499,
        births.child_mass_1500_2499,
        births.child_mass_2500_2999 + births.child_mass_3000_3999,
        births.child_mass_4000_or_more,
        births.ignored_child_mass
      ]
    }
  end
end
