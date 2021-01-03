defmodule HealthBoardWeb.DashboardLive.Fragments.IncidenceRateCard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{CardHeaderMenu, CardOffcanvasMenu, DataCard, IndeterminateLoading}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataCard id={{ @card.id }} :let={{ data: data }} width_l={{ 3 }} width_m={{ 1 }} >
      <template slot="header" :let={{ data: data }} >
        <CardHeaderMenu card={{ @card }} data={{ data }} />
      </template>

      <template slot="body" :let={{ data: data }} >
        <div class="uk-card-body">
          <h2 :if={{ Enum.any?(data) }}>{{ Humanize.number data.result.incidence_rate }}</h2>
          <small :if={{ Enum.any?(data) }}>/100 mil habitantes</small>
          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} />
    </DataCard>
    """
  end
end
