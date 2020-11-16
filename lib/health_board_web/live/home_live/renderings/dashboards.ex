defmodule HealthBoardWeb.HomeLive.Renderings.Dashboards do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias HealthBoardWeb.Cldr
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    show? = Map.get(assigns, :show_dashboards, true)
    dashboards = Map.get(assigns, :dashboards, [])

    ~L"""
    <div class="uk-section uk-section-xsmall">
      <%= title assigns, show? %>
      <%= if show? do %>
        <%= list assigns, dashboards %>
      <% end %>
    </div>
    """
  end

  defp title(assigns, show?) do
    icon_class = if show?, do: "gg-math-minus", else: "gg-math-plus"

    ~L"""
    <h2
      class="uk-heading-divider uk-margin-left uk-margin-right hb-va-center hb-clickable"
      phx-click="toggle_dashboards"
    >
      Painéis <i class="<%= icon_class %> hb-right"></i>
    </h2>
    """
  end

  defp list(assigns, dashboards) do
    ~L"""
    <div
      class="uk-grid uk-grid-small uk-grid-match uk-margin-left uk-margin-right uk-animation-fade"
      uk-height-match="target: > div > div > .uk-card-body"
      uk-grid
    >
      <%= if Enum.any? dashboards do %>
        <%= list_dashboards assigns, dashboards %>
      <% else %>
        <%= show_empty_dashboards_message assigns %>
      <% end %>
    </div>
    """
  end

  defp list_dashboards(assigns, dashboards) do
    ~L"""
    <%= for %{id: id, name: name, description: description, updated_at: updated_at} <- dashboards do %>
      <div class="uk-width-1-3@l">
        <div class="uk-card uk-card-default">
          <div class="uk-card-header">
            <h3 class="uk-card-title uk-margin-remove-bottom">
              <%= name %>
            </h3>
            <p class="uk-text-meta uk-margin-remove-top">
              <time datetime="<%= updated_at %>"><%= Cldr.DateTime.to_string! updated_at %></time>
            </p>
          </div>
          <div class="uk-card-body">
            <p><%= description %></p>
          </div>
          <div class="uk-card-footer">
            <a href="<%= Routes.dashboard_path @socket, :index, id %>" class="uk-button uk-button-text">Acessar</a>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  defp show_empty_dashboards_message(assigns) do
    ~L"""
    <div class="uk-card uk-card-body uk-width-1-2 uk-text-center uk-align-center">
      <h3 class="uk-card-title">Não há painéis disponíveis</h3>
      <p>Para definir um painel, favor utilizar o formulário abaixo.</p>
    </div>
    """
  end
end
