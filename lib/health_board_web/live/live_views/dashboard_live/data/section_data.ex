defmodule HealthBoardWeb.DashboardLive.SectionData do
  require Logger

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

  @spec cards(map, list) :: map
  def cards(payload, section_cards) do
    for section_card <- section_cards, into: %{} do
      fetch_card_data(section_card, payload)
    end
  end

  defp fetch_card_data(section_card, payload) do
    %{
      id: section_card_id,
      name: section_card_name,
      link: link?,
      filters: section_card_query_filters,
      card: %{id: id, indicator: indicator, name: card_name, description: description}
    } = section_card

    payload = fetch_query_filters(section_card_query_filters, payload)

    name = section_card_name || card_name
    link = if link?, do: Map.get(@cards_links, indicator.id), else: nil

    section_card_id = String.to_atom(section_card_id)

    section_card_data = %{
      name: name,
      description: description,
      indicator: indicator,
      link: link,
      data: %{},
      filters: %{},
      query_filters: %{}
    }

    try do
      %{view_data: data, filters: filters, query_filters: query_filters} =
        CardData.fetch(id, Map.merge(payload, %{view_data: %{}, id: section_card_id}))

      {section_card_id, Map.merge(section_card_data, %{data: data, filters: filters, query_filters: query_filters})}
    rescue
      error ->
        Logger.error(
          "Failed to build card #{section_card_id} data.\n" <>
            Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__)
        )

        {section_card_id, section_card_data}
    end
  end

  defp fetch_query_filters(section_card_query_filters, payload) do
    section_card_query_filters = for %{filter: f, value: v} <- section_card_query_filters, into: %{}, do: {f, v}
    section_card_query_filters = DataManager.parse_filters(section_card_query_filters)
    query_filters = Map.merge(payload.query_filters, section_card_query_filters)
    Map.put(payload, :query_filters, query_filters)
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
