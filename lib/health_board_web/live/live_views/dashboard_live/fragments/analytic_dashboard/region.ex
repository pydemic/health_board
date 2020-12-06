defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Region do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HeatTable
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true
  prop section_cards_ids, :list, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <HeatTable
          :if={{ @section.cards[section_card_id] }}
          :for={{ section_card_id <- @section_cards_ids }}
          card={{ @section.cards[section_card_id] }}
        />
      </Grid>
    </Section>
    """
  end
end
