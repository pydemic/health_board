defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HeatTable do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.Card
  alias Phoenix.LiveView

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} title={{ @card.name }} link={{ @card.link }} >
      <template slot="body">
        <div class="uk-card-body uk-overflow-auto">
          <table class="uk-table uk-table-small uk-table-middle uk-text-small hb-table">
            <thead>
              <tr>
                <th class="hb-table-empty"></th>
                <th :for={{ header <- @card.data.header }} class="hb-table-header uk-text-emphasis">
                  <div><span>{{ header }}</span></div>
                </th>
              </tr>
            </thead>
          </table>
        </div>
      </template>
    </Card>
    """
  end
end
