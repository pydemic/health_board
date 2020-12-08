defmodule HealthBoardWeb.DashboardLive.SectionData do
  require Logger

  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @cards_links %{
    "births" => "demographic",
    "crude_birth_rate" => "demographic",
    "death_rate" => "morbidity",
    "deaths" => "morbidity",
    "gender_ratio" => "demographic",
    "incidence" => "morbidity",
    "incidence_rate" => "morbidity",
    "population" => "demographic"
  }

  @spec assign(map) :: map
  def assign(%{section: %{cards: section_cards}, data: data, filters: filters, root_pid: root_pid}) do
    section_cards
    |> Enum.map(&fetch_card_data(&1, data, filters, root_pid))
    |> Enum.into(%{})
  rescue
    _error -> []
  end

  defp fetch_card_data(section_card, data, filters, root_pid) do
    %{
      id: section_card_id,
      name: section_card_name,
      link: link?,
      filters: section_card_filters,
      card: %{indicator: indicator, name: card_name, description: description} = card
    } = section_card

    section_card_filters = for %{filter: filter, value: value} <- section_card_filters, into: %{}, do: {filter, value}
    section_card_filters = DataManager.parse_filters(section_card_filters)

    filters = Map.merge(filters, section_card_filters)

    name = section_card_name || card_name
    link = if link?, do: Map.get(@cards_links, indicator.id), else: nil

    section_card_id = String.to_atom(section_card_id)

    section_card_data = %{
      name: name,
      description: description,
      indicator: indicator,
      link: link,
      data: %{},
      filters: %{}
    }

    try do
      %{data: data, filters: filters} =
        card
        |> CardData.new(section_card_id, data, filters, root_pid)
        |> CardData.fetch()
        |> CardData.assign()

      {section_card_id, Map.merge(section_card_data, %{data: data, filters: filters})}
    rescue
      error ->
        Logger.error(
          "Failed to build card #{section_card_id} data.\n" <>
            Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
        )

        {section_card_id, section_card_data}
    end
  end

  @spec fetch(map) :: map
  def fetch(%{section: %{id: id}} = section_data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [section_data])
  end

  @spec new(Info.Section.t(), map, map, pid) :: map
  def new(section, data, filters, root_pid) do
    %{section: section, data: data, filters: filters, root_pid: root_pid}
  end
end
