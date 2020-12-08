defmodule HealthBoardWeb.DashboardLive.DashboardData do
  require Logger

  alias HealthBoardWeb.DashboardLive.SectionData

  @spec sections(map, list) :: map
  def sections(payload, dashboard_sections) do
    for dashboard_section <- dashboard_sections, into: %{} do
      fetch_section_data(dashboard_section, payload)
    end
  end

  defp fetch_section_data(dashboard_section, payload) do
    %{section: %{id: id, name: name, description: description, cards: cards}} = dashboard_section

    id = String.to_atom(id)

    {
      id,
      %{
        id: id,
        name: name,
        description: description,
        cards: fetch_cards(id, cards, payload)
      }
    }
  end

  defp fetch_cards(id, cards, payload) do
    id
    |> SectionData.fetch(payload)
    |> SectionData.cards(cards)
  rescue
    error ->
      Logger.error(
        "Failed to build section #{id} data.\n" <>
          Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
      )

      []
  end

  @spec fetch(atom, map) :: map
  def fetch(id, payload) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [payload])
  end
end
