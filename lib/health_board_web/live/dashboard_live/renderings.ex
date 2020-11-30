defmodule HealthBoardWeb.DashboardLive.Renderings do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3]
  alias HealthBoardWeb.DashboardLive.{CanvasCardComponent, MapCardComponent, ScalarCardComponent, TableCardComponent}
  alias Phoenix.LiveView

  @spec maybe_render(map(), atom(), (map() -> LiveView.Rendered.t())) :: LiveView.Rendered.t()
  def maybe_render(assigns, key, function) do
    if Map.has_key?(assigns, key) do
      function.(assigns)
    else
      ~L""
    end
  end

  @spec maybe_render_chart(map(), atom(), keyword()) :: LiveView.Rendered.t()
  def maybe_render_chart(assigns, key, options \\ []) do
    case assigns[key] do
      nil -> ~L""
      payload -> live_component(assigns.socket, CanvasCardComponent, id: payload.id, payload: payload, options: options)
    end
  end

  @spec maybe_render_map(map(), atom(), keyword()) :: LiveView.Rendered.t()
  def maybe_render_map(assigns, key, options \\ []) do
    case assigns[key] do
      nil -> ~L""
      payload -> live_component(assigns.socket, MapCardComponent, id: payload.id, payload: payload, options: options)
    end
  end

  @spec maybe_render_table(map(), atom(), keyword()) :: LiveView.Rendered.t()
  def maybe_render_table(assigns, key, options \\ []) do
    case assigns[key] do
      nil -> ~L""
      payload -> live_component(assigns.socket, TableCardComponent, id: payload.id, payload: payload, options: options)
    end
  end

  @spec maybe_render_scalar(map(), atom(), keyword()) :: LiveView.Rendered.t()
  def maybe_render_scalar(assigns, key, options \\ []) do
    case Map.get(assigns, key) do
      nil -> ~L""
      payload -> live_component(assigns.socket, ScalarCardComponent, id: payload.id, payload: payload, options: options)
    end
  end

  def info(assigns, id, card) do
    ~L"""
    <div id="<%= id %>-info" uk-offcanvas="mode: push">
      <div class="uk-offcanvas-bar hb-offcanvas">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h2><i uk-icon="info"></i> Informações</h2>

        <p><%= card.description %></p>

        <hr>

        <h3>Indicador</h3>

        <h4><%= card.indicator.name %></h4>

        <p><%= card.indicator.description %></p>

        <hr>

        <%= if card.indicator.math do %>
        <h3>Fórmula</h3>

        <p><%= card.indicator.math %></p>

        <hr>
        <% end %>

        <h3>Visualização</h3>

        <h4><%= card.format.name %></h4>

        <p><%= card.format.description %></p>
      </div>
    </div>
    """
  end

  def data(assigns, id) do
    ~L"""
    <div id="<%= id %>-data" uk-offcanvas="mode: push">
      <div class="uk-offcanvas-bar hb-offcanvas">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h2><i uk-icon="list"></i> Dados</h2>
      </div>
    </div>
    """
  end

  def filters(assigns, id) do
    ~L"""
    <div id="<%= id %>-filters" uk-offcanvas="mode: push">
      <div class="uk-offcanvas-bar hb-offcanvas">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h2><i uk-icon="settings"></i> Filtros</h2>
      </div>
    </div>
    """
  end

  def sources(assigns, id) do
    ~L"""
    <div id="<%= id %>-sources" uk-offcanvas="mode: push">
      <div class="uk-offcanvas-bar hb-offcanvas">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h2><i uk-icon="quote-right"></i> Fontes</h2>
      </div>
    </div>
    """
  end
end
