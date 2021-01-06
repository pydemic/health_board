defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.History.HistoryIncidence do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    IncidenceEpicurve,
    IncidencePerMonth,
    IncidencePerWeek
  }

  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidenceEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <IncidencePerWeek card={{ Enum.at(@section.cards, 1) }} />
        <IncidencePerMonth card={{ Enum.at(@section.cards, 2) }} />
      </Grid>
    </Section>
    """
  end
end
