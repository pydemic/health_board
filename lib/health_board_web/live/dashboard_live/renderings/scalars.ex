defmodule HealthBoardWeb.DashboardLive.Renderings.Scalars do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3, live_component: 4]
  alias HealthBoardWeb.DashboardLive.{CardComponent, GridComponent}
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= live_component @socket, GridComponent, id: :scalar_cards do %>
      <%= if Map.has_key?(assigns, :population_data) do %>
        <%= live_component @socket, CardComponent,
          id: :population_data,
          title: "População residente",
          body: @population_data
          %>
      <% end %>

      <%= if Map.has_key?(assigns, :births_data) do %>
        <%= live_component @socket, CardComponent,
          id: :births_data,
          title: "Nascidos Vivos",
          body: @births_data
          %>
      <% end %>

      <%= if Map.has_key?(assigns, :crude_birth_rate_data) do %>
        <%= live_component @socket, CardComponent,
          id: :crude_birth_rate_data,
          title: "Taxa Bruta de Natalidade",
          body: @crude_birth_rate_data
          %>
      <% end %>
    <% end %>
    """
  end
end
