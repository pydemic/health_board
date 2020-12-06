defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Summary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidenceCard
          :for={{ {id, card} <- Enum.sort(@section.cards, &(elem(&1, 1).name <= elem(&2, 1).name)) }}
          id={{ id }}
          card={{ card }}
        />
      </Grid>
    </Section>
    """
  end
end
