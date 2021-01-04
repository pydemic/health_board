defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.PandemicSummary.PandemicCharts do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathRatePerAgeGender,
    DeathsPerAgeGender,
    DeathsPerRace,
    HospitalizationsPerComorbidity,
    HospitalizationsPerSymptom,
    IncidencePerAgeGender,
    IncidencePerRace,
    IncidenceRatePerAgeGender
  }

  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidencePerAgeGender card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRatePerAgeGender card={{ Enum.at(@section.cards, 1) }} />
        <DeathsPerAgeGender card={{ Enum.at(@section.cards, 2) }} />
        <DeathRatePerAgeGender card={{ Enum.at(@section.cards, 3) }} />
        <IncidencePerRace card={{ Enum.at(@section.cards, 4) }} />
        <DeathsPerRace card={{ Enum.at(@section.cards, 5) }} />
        <HospitalizationsPerSymptom card={{ Enum.at(@section.cards, 6) }} />
        <HospitalizationsPerComorbidity card={{ Enum.at(@section.cards, 7) }} />
      </Grid>
    </Section>
    """
  end
end
