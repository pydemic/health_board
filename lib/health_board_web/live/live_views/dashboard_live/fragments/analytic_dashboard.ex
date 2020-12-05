defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.ImmediateSummary
  alias HealthBoardWeb.LiveComponents.{Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    immediate_summary_key = :immediate_compulsory_analytic_summary

    ~H"""
    <Section>
      <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

      <ImmediateSummary
        :if={{ Map.has_key?(@dashboard.sections, immediate_summary_key) }}
        section={{ @dashboard.sections[immediate_summary_key] }}
      />
    </Section>
    """
  end
end
