defmodule HealthBoardWeb.DashboardLive.Components.ChartCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Card
  alias HealthBoardWeb.DashboardLive.Components.Fragments.NA
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :let={{ data: data }} element={{ @card }} params={{ @params }}>
      <canvas :show={{ data[:ready?] == true }} id={{ "canvas_#{@card.id}" }} phx-hook="Chart" height={{ 400 }}></canvas>
      <NA :if={{ data[:ready?] != true }} />
    </Card>
    """
  end
end
