defmodule HealthBoardWeb.DashboardLive.Components.Samples do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{ChartCard, ScalarCard, TableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec daily_epicurve(map, map) :: LiveView.Rendered.t()
  def daily_epicurve(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ daily_epicurve_params(params) }} />
    """
  end

  defp daily_epicurve_params(params) do
    params
  end

  @spec scalar(map, map) :: LiveView.Rendered.t()
  def scalar(assigns, params) do
    ~H"""
    <ScalarCard card={{ @element }} params={{ scalar_params(params) }} />
    """
  end

  defp scalar_params(params) do
    Map.merge(params, %{suffix: "testes"})
  end

  @spec top_ten_locations_table(map, map) :: LiveView.Rendered.t()
  def top_ten_locations_table(assigns, params) do
    ~H"""
    <TableCard card={{ @element }} params={{ top_ten_locations_table_params(params) }} />
    """
  end

  defp top_ten_locations_table_params(params) do
    Map.merge(params, %{slice: 0..9, with_index: true, headers: ~w[Local Testes]})
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
