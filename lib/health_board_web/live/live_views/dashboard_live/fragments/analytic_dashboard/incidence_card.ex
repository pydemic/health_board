defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.Card
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} title={{ @card.name }} link={{ @card.link }} border_color={{ @card.data[:color] }}>
      <template slot="body">
        <div class="uk-card-body">
          <h2>{{ Humanize.number @card.data.morbidity.total }}</h2>
          <small>{{ Humanize.number @card.data.deaths.total }} óbitos</small>
          <br/>
          <small>{{ Humanize.number @card.data.morbidity.average }} média de casos</small>
          <br/>
          <small>{{ Humanize.number @card.data.deaths.average }} média de óbitos</small>
          <br/>
          <small> Último caso em {{ Humanize.date @card.data.last_case_date }} </small>
          <br/>
          <small> Último óbito em {{ Humanize.date @card.data.extraction_date }} </small>
          <br/>
          <small> Casos extraídos em {{ Humanize.date @card.data.extraction_date }} </small>
          <br/>
          <small> Óbitos extraídos em {{ Humanize.date @card.data.extraction_date }} </small>
        </div>
      </template>
    </Card>
    """
  end
end
