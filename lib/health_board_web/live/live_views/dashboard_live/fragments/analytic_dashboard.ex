defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.{History, Summary}
  alias HealthBoardWeb.LiveComponents.{Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    immediate_summary_key = :immediate_compulsory_analytic_summary
    weekly_summary_key = :weekly_compulsory_analytic_summary

    immediate_history_key = :immediate_compulsory_analytic_history
    weekly_history_key = :weekly_compulsory_analytic_history

    ~H"""
    <Section>
      <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

      <Summary
        :if={{ false and Map.has_key?(@dashboard.sections, immediate_summary_key) }}
        section={{ @dashboard.sections[immediate_summary_key] }}
      />

      <Summary
        :if={{ false and Map.has_key?(@dashboard.sections, weekly_summary_key) }}
        section={{ @dashboard.sections[weekly_summary_key] }}
      />

      <History
        :if={{ Map.has_key?(@dashboard.sections, immediate_history_key) }}
        section={{ @dashboard.sections[immediate_history_key] }}
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
        :if={{ Map.has_key?(@dashboard.sections, weekly_history_key) }}
        section={{ @dashboard.sections[weekly_history_key] }}
        section_cards_ids={{[
          :weekly_compulsory_incidence_rate_per_year,
          :weekly_compulsory_death_rate_per_year
        ]}}
      />
    </Section>
    """
  end
end
