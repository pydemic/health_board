defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.{History, Region, Summary}
  alias HealthBoardWeb.LiveComponents.{Card, DashboardMenu, Grid, Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    sections = assigns.dashboard.sections

    if is_map(sections) do
      ~H"""
      <Section>
        <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

        <Summary
          :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_summary) }}
          section={{ sections[:immediate_compulsory_analytic_summary] }}
        />

        <Summary
          :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_summary) }}
          section={{ sections[:weekly_compulsory_analytic_summary] }} />

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

        <History
          :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_history) }}
          section={{ sections[:weekly_compulsory_analytic_history] }}
          section_cards_ids={{[
            :weekly_compulsory_incidence_rate_per_year,
            :weekly_compulsory_death_rate_per_year
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

        <Region
          :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_region) }}
          section={{ sections[:weekly_compulsory_analytic_region] }}
          section_cards_ids={{[
            :weekly_compulsory_incidence_rate_table,
            :weekly_compulsory_death_rate_table
          ]}}
        />

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
end
