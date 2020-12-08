defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HistoryChart do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardBodyCanvas, CardHeaderMenu, CardOffcanvasMenu}
  alias Phoenix.LiveView

  prop card_id, :atom, required: true

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card anchor={{ "to_#{@card_id}" }} :if={{ Enum.any?(@card.data) }} width_l={{ 2 }} width_m={{ 1 }}>
      <template slot="header">
        <CardHeaderMenu card_id={{ @card_id }} card={{ @card }} show_data={{ false }} show_link={{ false }} />
      </template>

      <template slot="body">
        <CardBodyCanvas id={{ @card_id }} />
      </template>

      <CardOffcanvasMenu card_id={{ @card_id }} card={{ @card }} show_data={{ false }} />
    </Card>
    """
  end
end
