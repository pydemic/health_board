defmodule HealthBoardWeb.DashboardLive.Fragments.HospitalizationsRanking do
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
        <CardHeaderMenu card={{ @card }} data={{ data }} />
      </template>

      <template slot="body" :let={{ data: data }} >
        <div class="uk-card-body uk-overflow-auto">
          <table :if={{ Enum.any?(data) }} class="uk-table uk-table-hover uk-table-small">
            <thead>
              <tr>
                <th></th>
                <th>Local</th>
                <th>Internações</th>
              </tr>
            </thead>

            <tbody>
              <tr :for.with_index={{ {element, index} <- data.result.ranking }}>
                <th>{{ index }}</th>
                <th>{{ element.name }}</th>
                <th>{{ Humanize.number element.hospitalizations}}</th>
              </tr>
            </tbody>
          </table>

          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} />
    </DataCard>
    """
  end
end
