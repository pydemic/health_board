defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsHospitalizationsSection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    HospitalizationsEpicurve,
    HospitalizationsMap,
    HospitalizationsPerComorbidity,
    HospitalizationsPerSymptom
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
        <HospitalizationsEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <HospitalizationsMap card={{ Enum.at(@section.cards, 1) }} />
        <HospitalizationsPerSymptom card={{ Enum.at(@section.cards, 2) }} />
        <HospitalizationsPerComorbidity card={{ Enum.at(@section.cards, 3) }} />
      </Grid>
    </Section>
    """
  end
end
