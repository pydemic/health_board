defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HistoryChart do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardBodyCanvas, CardHeaderMenu, CardOffcanvasMenu}
  alias Phoenix.LiveView

  prop card_id, :atom, required: true

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} title={{ @card.name }} link={{ @card.link }} width_l={{ 2 }} width_m={{ 1 }}>
      <template slot="header">
        <CardHeaderMenu card_id={{ @card_id }} card={{ @card }} />
      </template>

      <template slot="body">
        <CardBodyCanvas id={{ @card_id }} />
      </template>

      <CardOffcanvasMenu card_id={{ @card_id }} card={{ @card }} />
    </Card>
    """
  end
end
