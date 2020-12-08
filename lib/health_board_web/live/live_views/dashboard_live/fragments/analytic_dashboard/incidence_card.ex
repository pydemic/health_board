defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardHeaderMenu, CardOffcanvasMenu, Grid}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card_id, :atom, required: true
  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    %{data: data} = assigns.card

    color =
      case data[:overall_severity] do
        :below_average -> :success
        :on_average -> :warning
        :above_average -> :danger
        nil -> nil
      end

    ~H"""
    <Card anchor={{ "to_#{@card_id}" }} border_color={{ color }}>
      <template slot="header">
        <CardHeaderMenu card_id={{ @card_id }} card={{ @card }} border_color={{ color }} />
      </template>

      <template slot="body">
        <div class="uk-card-body">
          <Grid :if={{ Enum.any?(data) }}>
            <div class="uk-width-1-2">
              <h2>{{ Humanize.number data.morbidity.total }}</h2>
              <strong>Casos</strong>
              <small>Média:</small>
              <small>{{ Humanize.number data.morbidity.average }}</small>
              <small>Último registro:</small>
              <small>{{ Humanize.date data.morbidity.last_record_date }} </small>
            </div>

            <div class="uk-width-1-2">
              <h2>{{ Humanize.number data.deaths.total }}</h2>
              <strong>Óbitos</strong>
              <small>Média:</small>
              <small>{{ Humanize.number data.deaths.average }}</small>
              <small> Último registro:</small>
              <small>{{ Humanize.date data.deaths.last_record_date }} </small>
            </div>
          </Grid>
        </div>
      </template>

      <CardOffcanvasMenu card_id={{ @card_id }} card={{ @card }} />
    </Card>
    """
  end
end
