defmodule HealthBoardWeb.DashboardLive.SectionData do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.DashboardLive.CardData

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
  def assign(%{section: %{cards: section_cards}, data: data, filters: filters}) do
    for section_card <- section_cards, into: %{} do
      %{
        id: section_card_id,
        name: section_card_name,
        link: link?,
        filters: section_card_filters,
        card: %{indicator: indicator, name: card_name, description: description} = card
      } = section_card

      section_card_filters = for %{filter: filter, value: value} <- section_card_filters, into: %{}, do: {filter, value}
      filters = Map.merge(filters, section_card_filters)

      name = section_card_name || card_name
      link = if link?, do: Map.get(@cards_links, indicator.id), else: nil

      %{data: data, filters: filters} =
        card
        |> CardData.new(data, filters)
        |> CardData.fetch()
        |> CardData.assign()

      card_data = %{
        name: name,
        description: description,
        indicator: indicator,
        link: link,
        data: data,
        filters: filters
      }

      {String.to_atom(section_card_id), card_data}
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

  @spec new(Info.Section.t(), map, map) :: map
  def new(section, data, filters) do
    %{section: section, data: data, filters: filters}
  end
end
