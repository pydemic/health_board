# defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.ControlDiagrams do
#   use Surface.Component

#   alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.ControlDiagram
#   alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
#   alias Phoenix.LiveView

#   prop section, :map, required: true

#   prop section_cards_ids, :list, required: true

#   @spec render(map) :: LiveView.Rendered.t()
#   def render(assigns) do
#     cards = assigns.section.cards

#     ~H"""
#     <Section>
#       <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />

#       <Grid>
#         <ControlDiagram
#           :for={{ section_card_id <- @section_cards_ids }}
#           card_id={{ section_card_id }}
#           card={{ cards[section_card_id] }}
#         />
#       </Grid>
#     </Section>
#     """
#   end
# end
