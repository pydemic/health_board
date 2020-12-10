defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{CardHeaderMenu, CardOffcanvasMenu, DataCard, Grid, IndeterminateLoading}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataCard id={{ @card.id }} :let={{ data: data }} >
      <template slot="header" :let={{ data: data }} >
        <CardHeaderMenu card={{ @card }} data={{ data }} />
      </template>

      <template slot="body" :let={{ data: data }} >
        <div class="uk-card-body">
          <Grid :if={{ Enum.any?(data) }} >
            <div class="uk-width-1-2">
              <h2>{{ Humanize.number data.result.morbidity.total }}</h2>
              <strong>Casos</strong>
              <small>Média:</small>
              <small>{{ Humanize.number data.result.morbidity.average }}</small>
              <small>Último registro:</small>
              <small>{{ Humanize.date data.result.morbidity.last_record_date }} </small>
            </div>

            <div class="uk-width-1-2">
              <h2>{{ Humanize.number data.result.deaths.total }}</h2>
              <strong>Óbitos</strong>
              <small>Média:</small>
              <small>{{ Humanize.number data.result.deaths.average }}</small>
              <small> Último registro:</small>
              <small>{{ Humanize.date data.result.deaths.last_record_date }} </small>
            </div>
          </Grid>

          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} />
    </DataCard>
    """
  end
end
