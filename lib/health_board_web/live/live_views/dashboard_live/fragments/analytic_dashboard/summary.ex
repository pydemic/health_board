defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Summary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    section_cards = Enum.sort(assigns.section.cards, &(elem(&1, 1).name <= elem(&2, 1).name))

    ~H"""
    <Section>
      <SubSectionHeader
        title={{ @section.name }}
        description={{ @section.description }}
      />

      <Grid>
        <IncidenceCard
          :for={{ {id, card} <- section_cards }}
          card_id={{ id }}
          card={{ card }}
        />
      </Grid>
    </Section>
    """
  end
end
