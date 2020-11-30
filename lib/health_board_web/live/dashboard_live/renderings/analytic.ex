defmodule HealthBoardWeb.DashboardLive.Renderings.Analytic do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 4]
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.{GridComponent, Renderings}

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-section-navbar uk-text-center" uk-navbar>
      <a class="uk-navbar-item uk-logo" href="">Situação</a>
    </nav>

    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-sub-section-navbar uk-text-center" uk-navbar>
      <a class="uk-navbar-item uk-logo" href="">Notificação compulsória imediata</a>
    </nav>

    <div class="uk-section uk-section-xsmall">
      <h2 class="uk-margin-left">Sumário</h2>

      <%= live_component @socket, GridComponent, id: :immediates do %>
        <%= Renderings.maybe_render_scalar assigns, :botulism_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :chikungunya_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :cholera_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :yellow_fever_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :spotted_fever_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :hantavirus_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :malaria_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :plague_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :human_rabies_incidence, width_l: 5, width_m: 2 %>
        <%= Renderings.maybe_render_scalar assigns, :zika_incidence, width_l: 5, width_m: 2 %>
      <% end %>

      <h2 class="uk-margin-left">Histórico</h2>

      <%= live_component @socket, GridComponent, id: :immediates_history do %>
        <%= Renderings.maybe_render_chart assigns, :immediates_incidence_rate_per_year, width_l: 1, width_m: 1 %>
      <% end %>

      <h2 class="uk-margin-left">Estados</h2>

      <%= live_component @socket, GridComponent, id: :immediates_table do %>
        <%= Renderings.maybe_render_table assigns, :immediates_incidence_rate_table, width_l: 1, width_m: 1 %>
      <% end %>

      <h2 class="uk-margin-left">Controle</h2>

      <%= live_component @socket, GridComponent, id: :immediates_control do %>
        <%= Renderings.maybe_render_chart assigns, :botulism_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :chikungunya_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :cholera_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :yellow_fever_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :spotted_fever_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :hantavirus_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :malaria_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :plague_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :human_rabies_control_diagram, width_l: 2, width_m: 1 %>
        <%= Renderings.maybe_render_chart assigns, :zika_control_diagram, width_l: 2, width_m: 1 %>
      <% end %>
    </div>
    """
  end
end
