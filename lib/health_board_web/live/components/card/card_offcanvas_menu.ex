defmodule HealthBoardWeb.LiveComponents.CardOffcanvasMenu do
  use Surface.Component

  alias HealthBoardWeb.Helpers.Humanize
  alias HealthBoardWeb.LiveComponents.CardOffcanvasDescription
  alias Phoenix.LiveView

  prop card_id, :atom, required: true
  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ false }}>
      <div id={{"offcanvas-info-#{@card_id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Informações sobre {{ @card.name }}
          </h3>

          <dl class={{"uk-description-list", "hb-description-list"}}>
              <dt>Descrição:</dt>
              <dd>{{ @card.description }}</dd>
              <dt :if={{ not is_nil(@card.indicator.formula) }}>Indicador:</dt>
              <dd :if={{ not is_nil(@card.indicator.formula) }}>{{ @card.indicator.description }}</dd>
              <dt :if={{ not is_nil(@card.indicator.formula) }}>Fórmula:</dt>
              <dd :if={{ not is_nil(@card.indicator.formula) }}>{{ @card.indicator.formula }}</dd>
              <dt :if={{ not is_nil(@card.indicator.measurement_unit) }}>Unidade de medida:</dt>
              <dd :if={{ not is_nil(@card.indicator.measurement_unit) }}>{{ @card.indicator.measurement_unit }}</dd>
          </dl>

        </div>
      </div>

      <div id={{"offcanvas-data-#{@card_id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Dados de {{ @card.name }}
          </h3>

         <CardOffcanvasDescription data={{ @card.data }} />
        </div>
      </div>

      <div id={{"offcanvas-filters-#{@card_id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Filtros de {{ @card.name }}
          </h3>

         <CardOffcanvasDescription data={{ @card.filters }} />
        </div>
      </div>

      <div id={{"offcanvas-sources-#{@card_id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Fontes de {{ @card.name }}
          </h3>

            <div :if={{ not is_nil(@card.indicator.sources) }} :for={{ indicator_source <- @card.indicator.sources }}>
              <dl class={{"uk-description-list", "hb-description-list"}}>
                <dt>Nome:</dt>
                <dd>{{ indicator_source.source.name }}</dd>
                <dt>Descrição:</dt>
                <dd>{{ indicator_source.source.description }}</dd>
                <dt>Endereço da fonte:</dt>
                <dd><a href={{ indicator_source.source.link }} target="_blank">Clique aqui</a></dd>
                <dt>Frequência de atualização da base:</dt>
                <dd>{{ indicator_source.source.update_rate }}</dd>
                <dt>Data de extração:</dt>
                <dd>{{ Humanize.date(indicator_source.source.extraction_date) }}</dd>
              </dl>
            </div>

        </div>
      </div>

      <div id={{"offcanvas-labels-#{@card_id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Legenda de {{ @card.name }}
          </h3>
        </div>
      </div>
    </div>
    """
  end
end
