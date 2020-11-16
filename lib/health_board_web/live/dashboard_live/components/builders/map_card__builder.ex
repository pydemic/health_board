defmodule HealthBoardWeb.DashboardLive.MapCardBuilder do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3]
  alias HealthBoardWeb.DashboardLive.CardComponent
  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map(), map(), keyword()) :: LiveView.Component.t()
  def render(assigns, payload, options) do
    live_component(assigns.socket, CardComponent, build_card(assigns, payload, options))
  end

  defp build_card(assigns, payload, options) do
    %{id: id, card: card, data: %{ranges: ranges}} = payload

    options =
      [
        body_class: ["hb-map"],
        body_id: id,
        body_tags: [~s(phx-hook=Map)],
        footer_class: ["uk-hidden-hover"]
      ] ++ options

    [
      id: id,
      title: card.name,
      body_id: id,
      body: "",
      footer: footer(assigns, id),
      extras: extras(assigns, id, card, ranges),
      options: options
    ]
  end

  defp footer(assigns, id) do
    ~L"""
    <div class="uk-flex uk-flex-between">
      <div>
        <a href="" uk-toggle="target: #<%= id %>-info" uk-tooltip="Informações" uk-icon="info"></a>
      </div>
      <div>
        <a href="" uk-toggle="target: #<%= id %>-legends" uk-tooltip="Legenda" uk-icon="tag"></a>
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

  defp extras(assigns, id, card, ranges) do
    ~L"""
    <%= Renderings.info(assigns, id, card) %>
    <%= legend(assigns, id, ranges) %>
    <%= Renderings.data(assigns, id) %>
    <%= Renderings.filters(assigns, id) %>
    <%= Renderings.sources(assigns, id) %>
    """
  end

  defp legend(assigns, id, ranges) do
    ~L"""
    <div id="<%= id %>-modal" class="uk-flex-top" uk-modal>
      <div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical">
        <h2 class="uk-modal-title">Legenda</h2>

        <%= for %{color: color, text: text} <- ranges do %>
          <p class="hb-map-legend"><i style="background: <%= color %>"></i> <%= text %></p>
        <% end %>

        <button class="uk-modal-close-default" type="button" uk-close></button>
      </div>
    </div>
    """
  end
end
