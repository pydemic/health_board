defmodule HealthBoardWeb.DashboardLive.Components.LineChartCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Card
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :let={{ data: data }} element={{ @card }} params={{ @params }}>
      <canvas :show={{ Enum.any?(data) }} id={{ "canvas_#{@card.id}" }} phx-hook="Chart" height={{ 400 }}></canvas>
      <p :if={{ Enum.empty?(data) }} class="text-2xl font-bold">
        N/A
      </p>
    </Card>
    """
  end
end
