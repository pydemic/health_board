defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.LiveComponent

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.{History, Region, Summary}
  alias HealthBoardWeb.LiveComponents.{Card, DashboardMenu, Grid, Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  data index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    sections = assigns.dashboard.sections

    if is_map(sections) do
      ~H"""
      <Section>
        <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

        <div>
          <ul class="uk-child-width-expand uk-tab">
            <li class={{ "uk-active": @index == 0 }} :on-click="tab" phx-value-index={{ 0 }}>
              <a href="">
                Notificação Compulsória Imediata
              </a>
            </li>

            <li class={{ "uk-active": @index == 1 }} :on-click="tab" phx-value-index={{ 1 }}>
              <a href="">
                Notificação Compulsória Semanal
              </a>
            </li>
          </ul>
        </div>

        <div :show={{ @index == 0 }}>
          <Summary
            :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_summary) }}
            section={{ sections[:immediate_compulsory_analytic_summary] }}
          />

          <History
            :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_history) }}
            section={{ sections[:immediate_compulsory_analytic_history] }}
            section_cards_ids={{[
              :country_immediate_compulsory_incidence_rate_per_year,
              :country_immediate_compulsory_death_rate_per_year,
              :state_immediate_compulsory_incidence_rate_per_year,
              :state_immediate_compulsory_death_rate_per_year,
              :city_immediate_compulsory_incidence_rate_per_year,
              :city_immediate_compulsory_death_rate_per_year,
            ]}}
          />

          <Region
            :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_region) }}
            section={{ sections[:immediate_compulsory_analytic_region] }}
            section_cards_ids={{[
              :immediate_compulsory_incidence_rate_table,
              :immediate_compulsory_death_rate_table
            ]}}
          />
        </div>

        <div :show={{ @index == 1}}>
          <Summary
            :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_summary) }}
            section={{ sections[:weekly_compulsory_analytic_summary] }} />


          <History
            :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_history) }}
            section={{ sections[:weekly_compulsory_analytic_history] }}
            section_cards_ids={{[
              :weekly_compulsory_incidence_rate_per_year,
              :weekly_compulsory_death_rate_per_year
            ]}}
          />


          <Region
            :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_region) }}
            section={{ sections[:weekly_compulsory_analytic_region] }}
            section_cards_ids={{[
              :weekly_compulsory_incidence_rate_table,
              :weekly_compulsory_death_rate_table
            ]}}
          />
        </div>

        <DashboardMenu dashboard={{ @dashboard }} />
      </Section>
      """
    else
      title = "Carregando"
      content = "Gerando indicadores do painel. Em instantes o painel estará pronto para visualização."

      ~H"""
      <Section>
        <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

        <Grid>
          <Card
            width_l={{ 2 }}
            width_m={{ 1 }}
            title={{ title }}
            content={{ content }}
          />
        </Grid>
      </Section>
      """
    end
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("tab", data, socket) do
    {:noreply, assign(socket, :index, String.to_integer(data["index"]))}
  end
end
