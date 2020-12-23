defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusHospitalizationsSection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    IcuRateEpicurve,
    IcuRateMap
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
        <IcuRateEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <IcuRateMap card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
