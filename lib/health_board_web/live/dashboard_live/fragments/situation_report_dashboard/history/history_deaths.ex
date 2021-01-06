defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.History.HistoryDeaths do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathsEpicurve,
    DeathsPerMonth,
    DeathsPerWeek
  }

  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <DeathsEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <DeathsPerWeek card={{ Enum.at(@section.cards, 1) }} />
        <DeathsPerMonth card={{ Enum.at(@section.cards, 2) }} />
      </Grid>
    </Section>
    """
  end
end
