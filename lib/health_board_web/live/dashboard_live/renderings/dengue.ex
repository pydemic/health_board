defmodule HealthBoardWeb.DashboardLive.Renderings.Dengue do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 4]
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.{GridComponent, Renderings}

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-section-navbar uk-text-center" uk-navbar>
      <a class="uk-navbar-item uk-logo" href="">Doença ou Agravo: Dengue</a>
    </nav>

    <div class="uk-section uk-section-xsmall">
      <h2 class="uk-margin-left">Sumário</h2>

      <%= live_component @socket, GridComponent, id: :dengue_summary do %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_incidence %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_incidence_rate, suffix: :pcm %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_deaths %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_death_rate, suffix: :permille %>
      <% end %>

      <h2 class="uk-margin-left">Incidência</h2>

      <%= live_component @socket, GridComponent, id: :dengue_incidence_grid do %>
        <%= Renderings.maybe_render_map assigns, :dengue_incidence_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :dengue_incidence_per_sex, match_group: 1%>
          <%= Renderings.maybe_render_chart assigns, :dengue_incidence_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :dengue_incidence_rate_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :dengue_incidence_rate_per_age_group, match_group: 1 %>
        </div>
      <% end %>

      <h2 class="uk-margin-left">Óbitos</h2>

      <%= live_component @socket, GridComponent, id: :dengue_deaths_grid do %>
        <%= Renderings.maybe_render_map assigns, :dengue_deaths_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :dengue_deaths_per_year, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :dengue_deaths_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :dengue_deaths_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :dengue_deaths_per_race, match_group: 1 %>
        </div>
      <% end %>
    </div>
    """
  end
end
