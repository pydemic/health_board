defmodule HealthBoardWeb.DashboardLive.Renderings.ChartsAndMaps do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3, live_component: 4]
  alias HealthBoardWeb.DashboardLive.{CanvasCardComponent, GridComponent}
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= live_component @socket, GridComponent, id: :charts_and_maps_cards do %>
      <%= if Map.has_key?(assigns, :population_growth_data) do %>
        <%= live_component @socket, CanvasCardComponent,
          id: :population_growth,
          title: "Crescimento populacional"
          %>
      <% end %>

      <%= if Map.has_key?(assigns, :population_per_age_group_data) do %>
        <%= live_component @socket, CanvasCardComponent,
          id: :population_per_age_group,
          title: "Pirâmidade etária"
          %>
      <% end %>

      <%= if Map.has_key?(assigns, :population_per_sex_data) do %>
        <%= live_component @socket, CanvasCardComponent,
          id: :population_per_sex,
          title: "Razão de sexo"
          %>
      <% end %>
    <% end %>
    """
  end
end
