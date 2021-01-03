defmodule HealthBoardWeb.DashboardLive.Fragments.HealthProfessionalIncidenceRanking do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{CardHeaderMenu, CardOffcanvasMenu, DataCard, IndeterminateLoading}
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
          <table :if={{ Enum.any?(data) and Enum.any?(data.result.ranking) }} class="uk-table uk-table-hover uk-table-small">
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
                <th>{{ element.name }}</th>
                <th>{{ Humanize.number element.health_professional_incidence }}</th>
              </tr>
            </tbody>
          </table>

          <h3 :if={{ Enum.any?(data) and Enum.empty?(data.result.ranking) }}>Não há dados no dia</h3>

          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} show_data={{ false }} />
    </DataCard>
    """
  end
end
