defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.HospitalCapacity.HospitalCapacity do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.IcuRateTable
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IcuRateTable card={{ Enum.at(@section.cards, 0) }} />
      </Grid>
    </Section>
    """
  end
end
