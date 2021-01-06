defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.Summary.Summary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.SummaryTable
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <SummaryTable card={{ Enum.at(@section.cards, 0) }} />
      </Grid>
    </Section>
    """
  end
end
