defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardHeaderMenu, CardOffcanvasMenu}
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
    <Card border_color={{ color }}>
      <template slot="header">
        <CardHeaderMenu card_id={{ @card_id }} card={{ @card }} border_color={{ color }} />
      </template>

      <template slot="body">
        <div :if={{ Enum.any?(data) }} class="uk-card-body">
          <h2>{{ Humanize.number data.morbidity.total }}</h2>

          <small>{{ Humanize.number data.deaths.total }} óbitos</small>

          <br/>
          <small>{{ Humanize.number data.morbidity.average }} média de casos</small>

          <br/>
          <small>{{ Humanize.number data.deaths.average }} média de óbitos</small>

          <br/>
          <small> Último caso em {{ Humanize.date data.morbidity.last_record_date }} </small>

          <br/>
          <small> Último óbito em {{ Humanize.date data.deaths.last_record_date }} </small>
        </div>
      </template>

      <CardOffcanvasMenu card_id={{ @card_id }} card={{ @card }} />
    </Card>
    """
  end
end
