<%= live_component @socket, GridComponent, id: :dengue_scalar_grid do %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_incidence %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_incidence_rate, suffix: :pcm %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_deaths %>
        <%= Renderings.maybe_render_scalar assigns, :dengue_death_rate, suffix: :permille %>
      <% end %>

      <%= live_component @socket, GridComponent, id: :dengue_incidence_grid do %>
        <%= live_component @socket, GridComponent,
          id: :dengue_incidence_map_grid,
          options: child_grid_options
        do %>
          <%= Renderings.maybe_render_map assigns, :dengue_incidence_map, width_l: 1, width_m: 1 %>
        <% end %>

        <%= live_component @socket, GridComponent,
          id: :dengue_incidence_canvas_grid,
          options: child_grid_options
        do %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_incidence_per_sex, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_incidence_per_age_group, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_incidence_rate_per_sex, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_incidence_rate_per_age_group, width_l: 2, width_m: 2 %>
        <% end %>
      <% end %>

      <%= live_component @socket, GridComponent, id: :dengue_deaths_grid do %>
        <%= live_component @socket, GridComponent, id: :dengue_deaths_map_grid, options: child_grid_options do %>
          <%= Renderings.maybe_render_map assigns, :dengue_deaths_map, width_l: 1, width_m: 1 %>
        <% end %>

        <%= live_component @socket, GridComponent, id: :dengue_deaths_canvas_grid, options: child_grid_options do %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_deaths_per_year, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_deaths_per_sex, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_deaths_per_age_group, width_l: 2, width_m: 2 %>
          <%= Renderings.maybe_render_canvas assigns, :dengue_deaths_per_race, width_l: 2, width_m: 2 %>
        <% end %>
      <% end %>

      <%= live_component @socket, GridComponent, id: :dengue_control_grid do %>
        <%= Renderings.maybe_render_canvas assigns, :dengue_incidence_control_diagram %>
      <% end %>
