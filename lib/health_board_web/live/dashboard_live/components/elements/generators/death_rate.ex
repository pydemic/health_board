defmodule HealthBoardWeb.DashboardLive.Components.DeathRate do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{ChoroplethMapsCard, ScalarCard, TableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec choropleth_maps(map, map) :: LiveView.Rendered.t()
  def choropleth_maps(assigns, params) do
    ~H"""
    <ChoroplethMapsCard card={{ @element }} params={{ choropleth_maps_params(params) }} />
    """
  end

  defp choropleth_maps_params(params) do
    Map.merge(params, %{suffix: "/ 100 mil habitantes"})
  end

  @spec scalar(map, map) :: LiveView.Rendered.t()
  def scalar(assigns, params) do
    ~H"""
    <ScalarCard card={{ @element }} params={{ scalar_params(params) }} />
    """
  end

  defp scalar_params(params) do
    Map.merge(params, %{suffix: "/ 100 mil habitantes"})
  end

  @spec top_ten_locations_table(map, map) :: LiveView.Rendered.t()
  def top_ten_locations_table(assigns, params) do
    ~H"""
    <TableCard card={{ @element }} params={{ top_ten_locations_table_params(params) }} />
    """
  end

  defp top_ten_locations_table_params(params) do
    Map.merge(params, %{slice: 0..9, with_index: true, headers: ["Local", "Taxa (/100 mil hab.)"]})
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
