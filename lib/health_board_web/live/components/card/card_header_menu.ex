defmodule HealthBoardWeb.LiveComponents.CardHeaderMenu do
  use Surface.Component, slot: "header"

  alias Phoenix.LiveView

  prop card_id, :atom, required: true
  prop card, :map, required: true

  prop show_data, :boolean, default: true
  prop show_info, :boolean, default: true
  prop show_filters, :boolean, default: true
  prop show_sources, :boolean, default: true
  prop show_labels, :boolean, default: false

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-card-header", "uk-visible-toggle", "show-when-not-hover-container", "uk-transition-toggle", "hb-border": @card.data[:color], "hb-border-bottom": @card.data[:color], "hb-border-#{@card.data[:color]}": @card.data[:color] }}>
      <h3 class={{"uk-card-title", "show-when-not-hover"}}>
        {{ @card.name }}
      </h3>

      <div class={{ "uk-hidden-hover", "uk-transition-slide-top", "uk-flex", "uk-flex-middle", "uk-flex-between", "hb-card-menu"}}>
        <div :if={{ @card[:link] }}>
          <a href={{ @card.link }} uk-tooltip="Ver painel">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><path d="M0 0h24v24H0z" fill="none"/><path d="M19 4H5c-1.11 0-2 .9-2 2v12c0 1.1.89 2 2 2h4v-2H5V8h14v10h-4v2h4c1.1 0 2-.9 2-2V6c0-1.1-.89-2-2-2zm-7 6l-4 4h3v6h2v-6h3l-4-4z"/></svg>
          </a>
        </div>
        <div :if={{ @show_info }}>
          <a href={{"#offcanvas-info-#{@card_id}"}} uk-tooltip="Informações" uk-toggle>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><path d="M0 0h24v24H0z" fill="none"/><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
          </a>
        </div>
        <div :if={{ @show_data }}>
          <a href={{"#offcanvas-data-#{@card_id}"}} uk-tooltip="Dados" uk-toggle>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><path d="M0 0h24v24H0z" fill="none"/><path d="M4 14h4v-4H4v4zm0 5h4v-4H4v4zM4 9h4V5H4v4zm5 5h12v-4H9v4zm0 5h12v-4H9v4zM9 5v4h12V5H9z"/></svg>
          </a>
        </div>
        <div :if={{ @show_filters }}>
          <a href={{"#offcanvas-filters-#{@card_id}"}} uk-tooltip="Filtros" uk-toggle>
          <svg xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><g><path d="M0,0h24 M24,24H0" fill="none"/><path d="M4.25,5.61C6.27,8.2,10,13,10,13v6c0,0.55,0.45,1,1,1h2c0.55,0,1-0.45,1-1v-6c0,0,3.72-4.8,5.74-7.39 C20.25,4.95,19.78,4,18.95,4H5.04C4.21,4,3.74,4.95,4.25,5.61z"/><path d="M0,0h24v24H0V0z" fill="none"/></g></svg>
          </a>
        </div>
        <div :if={{ @show_sources }}>
          <a href={{"#offcanvas-sources-#{@card_id}"}} uk-tooltip="Fontes" uk-toggle>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><path d="M0 0h24v24H0z" fill="none"/><path d="M6 17h3l2-4V7H5v6h3zm8 0h3l2-4V7h-6v6h3z"/></svg>
          </a>
        </div>
        <div :if={{ @show_labels }}>
          <a href={{"#offcanvas-labels-#{@card_id}"}} uk-tooltip="Legenda" uk-toggle>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="black" width="24px" height="24px"><path d="M0 0h24v24H0z" fill="none"/><path d="M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z"/></svg>
          </a>
        </div>
      </div>
    </div>
    """
  end
end
