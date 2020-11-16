defmodule HealthBoardWeb.DashboardLive.CanvasCardBuilder do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3]
  alias HealthBoardWeb.DashboardLive.CardComponent
  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map(), map(), keyword()) :: LiveView.Component.t()
  def render(assigns, payload, options) do
    live_component(assigns.socket, CardComponent, build_card(assigns, payload, options))
  end

  defp build_card(assigns, payload, options) do
    %{id: id, card: card} = payload

    [
      id: id,
      title: card.name,
      body: body(assigns, id),
      footer: footer(assigns, id),
      extras: extras(assigns, id, card),
      options: [footer_class: ["uk-hidden-hover"]] ++ options
    ]
  end

  defp body(assigns, id) do
    ~L"""
    <canvas id="<%= id %>" height="260" phx-hook="Chart"></canvas>
    """
  end

  defp footer(assigns, id) do
    ~L"""
    <div class="uk-flex uk-flex-between">
      <div>
        <a href="" uk-toggle="target: #<%= id %>-info" uk-tooltip="Informações" uk-icon="info"></a>
      </div>
      <div>
        <a href="" uk-toggle="target: #<%= id %>-data" uk-tooltip="Dados" uk-icon="list"></a>
      </div>
      <div>
        <a href="" uk-toggle="target: #<%= id %>-filters" uk-tooltip="Filtros" uk-icon="settings"></a>
      </div>
      <div>
        <a href="" uk-toggle="target: #<%= id %>-sources" uk-tooltip="Fontes" uk-icon="quote-right"></a>
      </div>
    </div>
    """
  end

  defp extras(assigns, id, card) do
    ~L"""
    <%= Renderings.info(assigns, id, card) %>
    <%= Renderings.data(assigns, id) %>
    <%= Renderings.filters(assigns, id) %>
    <%= Renderings.sources(assigns, id) %>
    """
  end
end
