defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.ControlDiagram do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardBodyCanvas}
  alias Phoenix.LiveView

  prop id, :atom, required: true

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} title={{ @card.name }} link={{ @card.link }} width_l={{ 2 }} width_m={{ 1 }}>
      <template slot="body">
        <CardBodyCanvas id={{ @id }} />
      </template>
    </Card>
    """
  end
end
