defmodule HealthBoardWeb.LiveComponents.CardOffcanvasMenu do
  use Surface.LiveComponent, slot: "header"

  alias Phoenix.LiveView

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="hb-hide">
      <div id={{"offcanvas-info-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Informações sobre {{ @card.name }}
          </h3>

          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

        </div>
      </div>

      <div id={{"offcanvas-data-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Dados de {{ @card.name }}
          </h3>

          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

        </div>
      </div>

      <div id={{"offcanvas-filters-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Filtros de {{ @card.name }}
          </h3>

          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

        </div>
      </div>

      <div id={{"offcanvas-sources-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Fontes de {{ @card.name }}
          </h3>

          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

        </div>
      </div>

      <div id={{"offcanvas-labels-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Legenda de {{ @card.name }}
          </h3>

          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

        </div>
      </div>
    </div>
    """
  end
end
