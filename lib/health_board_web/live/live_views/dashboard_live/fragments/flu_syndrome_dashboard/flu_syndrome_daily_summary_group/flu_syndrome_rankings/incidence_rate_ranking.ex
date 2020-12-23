defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.IncidenceRateRanking do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{CardHeaderMenu, CardOffcanvasMenu, DataCard, IndeterminateLoading}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataCard id={{ @card.id }} :let={{ data: data }} width_l={{ 2 }} width_m={{ 1 }} >
      <template slot="header" :let={{ data: data }} >
        <CardHeaderMenu card={{ @card }} data={{ data }} show_data={{ false }} />
      </template>

      <template slot="body" :let={{ data: data }} >
        <div class="uk-card-body uk-overflow-auto">
          <table :if={{ Enum.any?(data) }} class="uk-table uk-table-hover uk-table-small">
            <thead>
              <tr>
                <th></th>
                <th>Local</th>
                <th>Taxa</th>
              </tr>
            </thead>

            <tbody>
              <tr :for.with_index={{ {element, index} <- data.result.ranking }}>
                <th>{{ index + 1 }}</th>
                <th>{{ element.location }}</th>
                <th>{{ Humanize.number element.incidence_rate }}</th>
              </tr>
            </tbody>
          </table>

          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} show_data={{ false }} />
    </DataCard>
    """
  end
end
