defmodule HealthBoardWeb.DashboardLive.Components.CovidReports.ICUOccupationRate do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{ChartCard, ChoroplethMapCard, HeatmapTableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec chart(map, map) :: LiveView.Rendered.t()
  def chart(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ params }} />
    """
  end

  @spec choropleth_map(map, map) :: LiveView.Rendered.t()
  def choropleth_map(assigns, params) do
    ~H"""
    <ChoroplethMapCard card={{ @element }} params={{ choropleth_map_params(params) }} />
    """
  end

  defp choropleth_map_params(params) do
    Map.merge(params, %{suffix: "%"})
  end

  @spec heatmap_table(map, map) :: LiveView.Rendered.t()
  def heatmap_table(assigns, params) do
    ~H"""
    <HeatmapTableCard card={{ @element }} params={{ params }} />
    """
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
