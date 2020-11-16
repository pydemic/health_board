defmodule HealthBoardWeb.DashboardLive.Renderings.Demographic do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 4]
  alias HealthBoardWeb.DashboardLive.{GridComponent, Renderings}
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <%= title assigns %>

    <div class="uk-section uk-section-xsmall">
      <%= live_component @socket, GridComponent, id: :demographic_scalar_cards do %>
        <%= Renderings.maybe_render_scalar assigns, :population %>
        <%= Renderings.maybe_render_scalar assigns, :sex_ratio, suffix: :percent %>
        <%= Renderings.maybe_render_scalar assigns, :births %>
        <%= Renderings.maybe_render_scalar assigns, :crude_birth_rate, suffix: :permille %>
      <% end %>

      <%= live_component @socket, GridComponent, id: :demographic_chart_cards do %>
        <%= Renderings.maybe_render_map assigns, :population_map %>
        <%= Renderings.maybe_render_chart assigns, :population_growth %>
        <%= Renderings.maybe_render_chart assigns, :population_per_age_group %>
        <%= Renderings.maybe_render_chart assigns, :population_per_sex %>
        <%= Renderings.maybe_render_map assigns, :crude_birth_rate_map %>
        <%= Renderings.maybe_render_chart assigns, :births_per_year %>
        <%= Renderings.maybe_render_chart assigns, :crude_birth_rate_per_year %>
        <%= Renderings.maybe_render_chart assigns, :births_per_child_mass %>
        <%= Renderings.maybe_render_chart assigns, :births_per_child_sex %>
        <%= Renderings.maybe_render_chart assigns, :births_per_delivery %>
        <%= Renderings.maybe_render_chart assigns, :births_per_gestation_duration %>
        <%= Renderings.maybe_render_chart assigns, :births_per_location %>
        <%= Renderings.maybe_render_chart assigns, :births_per_mother_age %>
        <%= Renderings.maybe_render_chart assigns, :births_per_prenatal_consultations %>
      <% end %>
    </div>
    """
  end

  defp title(assigns) do
    ~L"""
    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-section-navbar" uk-navbar>
      <a class="uk-navbar-item uk-logo" href="">Demográfico</a>
    </nav>
    """
  end
end
