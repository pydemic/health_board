defmodule HealthBoardWeb.DashboardLive.CardData do
  alias HealthBoardWeb.DashboardLive.DataManager
  alias HealthBoardWeb.DashboardLive.Components.DataCard

  @spec request_to_fetch(pid, map, map) :: :ok
  def request_to_fetch(pid, section_card, data) do
    send(pid, {:fetch_section_card, section_card, data})
    :ok
  end

  @spec fetch(pid, map, map) :: any
  def fetch(pid, %{id: section_card_id} = section_card, data) do
    data =
      data
      |> Map.merge(parse_filters(section_card.filters))
      |> Map.put(:section_card_id, section_card_id)

    sub_module =
      "#{section_card.card_id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    result =
      __MODULE__
      |> Module.concat(sub_module)
      |> apply(:fetch, [pid, section_card.card, data])

    unless is_nil(result) do
      DataCard.fetch(section_card_id, result)
    end

    result
  end

  defp parse_filters(section_card_filters) do
    for %{filter: filter, value: value} <- section_card_filters, into: %{} do
      {filter, value}
    end
    |> DataManager.parse_filters()
  end
end
