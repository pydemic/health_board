defmodule HealthBoardWeb.DashboardLive.Components.Deaths do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{ScalarCard, TableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec scalar(map, map) :: LiveView.Rendered.t()
  def scalar(assigns, params) do
    ~H"""
    <ScalarCard card={{ @element }} params={{ scalar_params(params) }} />
    """
  end

  defp scalar_params(params) do
    Map.merge(params, %{suffix: "óbitos"})
  end

  @spec top_ten_locations_table(map, map) :: LiveView.Rendered.t()
  def top_ten_locations_table(assigns, params) do
    ~H"""
    <TableCard card={{ @element }} params={{ top_ten_locations_table_params(params) }} />
    """
  end

  defp top_ten_locations_table_params(params) do
    Map.merge(params, %{slice: 0..9, with_index: true, headers: ~w[Local Óbitos]})
  end

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      Do not use this function.
    </div>
    """
  end
end
