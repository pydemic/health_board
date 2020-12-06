defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardHeaderMenu, CardOffcanvasMenu}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop id, :atom, required: true

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} border_color={{ @card.data[:color] }}>
      <template slot="header">
        <CardHeaderMenu id={{ @id }} card={{ @card }} />
      </template>
      <template slot="body">
        <div class="uk-card-body">
          <h2>{{ Humanize.number @card.data.year_morbidity.total }}</h2>
          <small>{{ Humanize.number @card.data.year_deaths.total }} óbitos</small>
          <br/>
          <small>{{ Humanize.number @card.data.year_morbidity.average }} média de casos</small>
          <br/>
          <small>{{ Humanize.number @card.data.year_deaths.average }} média de óbitos</small>
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

      <CardOffcanvasMenu id={{ @id }} card={{ @card }} />
    </Card>
    """
  end
end
