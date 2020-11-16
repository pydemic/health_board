defmodule HealthBoardWeb.DashboardLive.Renderings.Violence do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 4]
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.{GridComponent, Renderings}

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <nav class="uk-navbar-container uk-navbar-transparent uk-light hb-section-navbar uk-text-center" uk-navbar>
      <a class="uk-navbar-item uk-logo" href="">Doença ou Agravo: Violência</a>
    </nav>

    <div class="uk-section uk-section-xsmall">
      <h2 class="uk-margin-left">Sumário</h2>

      <%= live_component @socket, GridComponent, id: :violence_summary do %>
        <%= Renderings.maybe_render_scalar assigns, :violence_incidence %>
        <%= Renderings.maybe_render_scalar assigns, :violence_incidence_rate, suffix: :pcm %>
        <%= Renderings.maybe_render_scalar assigns, :violence_domestic_deaths, title_suffix: "Violência doméstica"%>
        <%= Renderings.maybe_render_scalar assigns, :violence_domestic_death_rate, suffix: :permille, title_suffix: "Violência doméstica" %>
        <%= Renderings.maybe_render_scalar assigns, :violence_sexual_deaths, title_suffix: "Violência sexual" %>
        <%= Renderings.maybe_render_scalar assigns, :violence_sexual_death_rate, suffix: :permille, title_suffix: "Violência sexual" %>
        <%= Renderings.maybe_render_scalar assigns, :violence_suicide_deaths, title_suffix: "Suicídio" %>
        <%= Renderings.maybe_render_scalar assigns, :violence_suicide_death_rate, suffix: :permille, title_suffix: "Suicídio" %>
      <% end %>

      <h2 class="uk-margin-left">Incidência</h2>

      <%= live_component @socket, GridComponent, id: :violence_incidence_grid do %>
        <%= Renderings.maybe_render_map assigns, :violence_incidence_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :violence_incidence_per_sex, match_group: 1%>
          <%= Renderings.maybe_render_chart assigns, :violence_incidence_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_incidence_rate_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_incidence_rate_per_age_group, match_group: 1 %>
        </div>
      <% end %>

      <h2 class="uk-margin-left">Óbitos - Violência Doméstica</h2>

      <%= live_component @socket, GridComponent, id: :violence_domestic_deaths_grid do %>
        <%= Renderings.maybe_render_map assigns, :violence_domestic_deaths_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :violence_domestic_deaths_per_year, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_domestic_deaths_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_domestic_deaths_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_domestic_deaths_per_race, match_group: 1 %>
        </div>
      <% end %>

      <h2 class="uk-margin-left">Óbitos - Violência Sexual</h2>

      <%= live_component @socket, GridComponent, id: :violence_sexual_deaths_grid do %>
        <%= Renderings.maybe_render_map assigns, :violence_sexual_deaths_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :violence_sexual_deaths_per_year, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_sexual_deaths_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_sexual_deaths_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_sexual_deaths_per_race, match_group: 1 %>
        </div>
      <% end %>

      <h2 class="uk-margin-left">Óbitos - Suicídio</h2>

      <%= live_component @socket, GridComponent, id: :violence_suicide_deaths_grid do %>
        <%= Renderings.maybe_render_map assigns, :violence_suicide_deaths_map, width_l: 2, width_m: 1 %>

        <div class="uk-width-1-2@l uk-grid-match uk-grid-small" uk-grid uk-height-match=".hb-match-1">
          <%= Renderings.maybe_render_chart assigns, :violence_suicide_deaths_per_year, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_suicide_deaths_per_sex, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_suicide_deaths_per_age_group, match_group: 1 %>
          <%= Renderings.maybe_render_chart assigns, :violence_suicide_deaths_per_race, match_group: 1 %>
        </div>
      <% end %>
    </div>
    """
  end
end
