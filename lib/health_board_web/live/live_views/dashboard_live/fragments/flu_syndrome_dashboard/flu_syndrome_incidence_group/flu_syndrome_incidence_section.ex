defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromeIncidenceSection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    IncidenceEpicurve,
    IncidencePerAgeGender,
    IncidencePerMonth,
    IncidencePerWeek,
    IncidenceRateMap,
    PandemicIncidenceMap
  }

  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidenceEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <IncidencePerMonth card={{ Enum.at(@section.cards, 1) }} />
        <IncidencePerWeek card={{ Enum.at(@section.cards, 2) }} />
        <IncidenceRateMap card={{ Enum.at(@section.cards, 3) }} />
        <PandemicIncidenceMap card={{ Enum.at(@section.cards, 4) }} />
        <IncidencePerAgeGender card={{ Enum.at(@section.cards, 5) }} />
      </Grid>
    </Section>
    """
  end
end
