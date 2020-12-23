defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsIncidenceSection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    IncidenceEpicurve,
    IncidencePerAgeGender,
    IncidencePerMonth,
    IncidencePerRace,
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
        <IncidencePerRace card={{ Enum.at(@section.cards, 6) }} />
      </Grid>
    </Section>
    """
  end
end
