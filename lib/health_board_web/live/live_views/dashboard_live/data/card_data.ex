defmodule HealthBoardWeb.DashboardLive.CardData do
  alias HealthBoard.Contexts.Info

  @spec assign(map) :: map
  def assign(%{view_data: data, filters: filters}) do
    %{data: data, filters: filters}
  end

  @spec fetch(map) :: map
  def fetch(%{card: %{id: id}} = card_data) do
    sub_module =
      "#{id}"
      |> Recase.to_pascal()
      |> String.to_atom()

    __MODULE__
    |> Module.concat(sub_module)
    |> apply(:fetch, [card_data])
  end

  @spec new(Info.Card.t(), atom, map, map) :: map
  def new(card, section_card_id, data, filters) do
    %{id: section_card_id, card: card, data: data, filters: filters, view_data: %{}}
  end
end
