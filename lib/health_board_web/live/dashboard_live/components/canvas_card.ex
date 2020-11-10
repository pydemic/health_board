defmodule HealthBoardWeb.DashboardLive.CanvasCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="uk-width-1-3@l uk-width-1-2@m">
      <div class="uk-card uk-card-hover uk-card-default">
        <div class="uk-card-header">
          <h3 class="uk-card-title"><%= @title %></h3>
        </div>

        <div class="uk-card-body">
          <canvas id="<%= @id %>" height="260" phx-hook="Chart"></canvas>
        </div>

        <%= if assigns[:footer] do %>
        <div class="uk-card-footer">
          <%= @footer %>
        </div>
        <% end %>
      </div>
    </div>
    """
  end
end
