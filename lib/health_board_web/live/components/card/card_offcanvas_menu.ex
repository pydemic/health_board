defmodule HealthBoardWeb.LiveComponents.CardOffcanvasMenu do
  use Surface.LiveComponent, slot: "header"

  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop card, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="hb-none">
      <div id={{"offcanvas-info-#{@id}"}} uk-modal>
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

      <div id={{"offcanvas-data-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Dados de {{ @card.name }}
          </h3>

          {{ humanize_value(assigns, @card.data) }}

        </div>
      </div>

      <div id={{"offcanvas-filters-#{@id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Filtros de {{ @card.name }}
          </h3>

          {{ humanize_value(assigns, @card.filters) }}

        </div>
      </div>

      <div id={{"offcanvas-sources-#{@id}"}} uk-modal>
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

      <div id={{"offcanvas-labels-#{@id}"}} uk-modal>
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

  def humanize_value(assigns, %Date{} = value) do
    ~H"""
    <dd>{{ Humanize.date(value) }}</dd>
    """
  end

  def humanize_value(assigns, map_or_list) when is_map(map_or_list) or is_list(map_or_list) do
    ~H"""
    <div class={{ "uk-description-list", "hb-description-list" }} :for={{ value <- map_or_list }}>
      {{ humanize_value(assigns, value) }}
    </div>
    """
  end

  def humanize_value(assigns, {key, value}) do
    case key do
      :color ->
        ~H""

      _key ->
        ~H"""
          <br/>
          <dt>{{ Humanize.translate_key(key) }} </dt>
          <dd>{{ humanize_value(assigns, value) }} </dd>
        """
    end
  end

  def humanize_value(assigns, value) do
    value =
      cond do
        is_nil(value) -> "N/A"
        is_integer(value) -> Humanize.number(value)
        is_float(value) -> Humanize.number(value)
        true -> value
      end

    ~H"""
    {{ value }}
    """
  end
end
