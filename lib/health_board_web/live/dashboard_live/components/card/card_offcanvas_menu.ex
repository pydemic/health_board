defmodule HealthBoardWeb.DashboardLive.Components.CardOffcanvasMenu do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.CardOffcanvasDescription
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop data, :map

  prop show_info, :boolean, default: true
  prop show_data, :boolean, default: true
  prop show_labels, :boolean, default: false
  prop show_filters, :boolean, default: true
  prop show_sources, :boolean, default: true

  prop suffix, :string, default: ""

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ false }}>
      <div :if={{ @show_info }} id={{"offcanvas-info-#{@card.id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Informações sobre {{ @card.name || @card.card.name }}
          </h3>

          <dl class={{"uk-description-list", "hb-description-list"}}>
            <dt>Descrição</dt>
            <dd>{{ @card.card.description }}</dd>
            <dt>Indicador</dt>
            <dd>{{ @card.card.indicator.description }}</dd>
            <dt>Fórmula</dt>
            <dd>{{ @card.card.indicator.formula }}</dd>
            <dt>Unidade de medida</dt>
            <dd>{{ @card.card.indicator.measurement_unit || "Valor absoluto" }}</dd>
          </dl>

        </div>
      </div>

      <div :if={{ @show_data }} id={{"offcanvas-data-#{@card.id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Dados de {{ @card.name || @card.card.name }}
          </h3>

         <CardOffcanvasDescription data={{ @data[:result] || %{} }} />
        </div>
      </div>

      <div :if={{ @show_labels }} id={{"offcanvas-labels-#{@card.id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Legenda para {{ @card.name || @card.card.name }}
          </h3>

          <div :if={{ Map.has_key?(@data, :labels) }}>
            <div :for={{ %{from: from, to: to, group: group} <- @data.labels }} class="uk-width-1-1">
              <div class={{ "hb-label": group, "hb-choropleth-#{group}": group }}></div>
              {{ label_description(from, to, @suffix) }}
              <br/>
            </div>
          </div>

        </div>
      </div>

      <div if={{ @show_filters }} id={{"offcanvas-filters-#{@card.id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Filtros de {{ @card.name || @card.card.name }}
          </h3>

         <CardOffcanvasDescription data={{ @data[:filters] || %{} }} />
        </div>
      </div>

      <div if={{ @show_sources }} id={{"offcanvas-sources-#{@card.id}"}} uk-modal>
        <div class="uk-offcanvas-bar">
          <button class="uk-modal-close" type="button" uk-close></button>

          <h3>
          Fontes de {{ @card.name || @card.card.name }}
          </h3>

          <div :for={{ indicator_source <- @card.card.indicator.sources }}>
            <dl class={{"uk-description-list", "hb-description-list"}}>
              <dt>Nome</dt>
              <dd>{{ indicator_source.source.name }}</dd>
              <dt>Descrição</dt>
              <dd>{{ indicator_source.source.description }}</dd>
              <dt>Endereço da fonte</dt>
              <dd><a href={{ indicator_source.source.link }} target="_blank">Clique aqui</a></dd>
              <dt>Frequência de atualização da base</dt>
              <dd>{{ indicator_source.source.update_rate }}</dd>
              <dt>Data de extração</dt>
              <dd>{{ Humanize.date(indicator_source.source.extraction_date) }}</dd>
              <dt>Data da última atualização</dt>
              <dd>{{ Humanize.date(indicator_source.source.last_update_date) }}</dd>
              <dt>Data do último registro</dt>
              <dd>{{ Humanize.date(@data[:last_record_date]) }}</dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp label_description(from, to, suffix) do
    case {from, to} do
      {nil, to} -> "#{Humanize.number(to)}#{suffix}"
      {from, nil} -> "#{Humanize.number(from)}#{suffix} ou mais"
      _ -> "Entre #{Humanize.number(from)}#{suffix} e #{Humanize.number(to)}#{suffix}"
    end
  end
end
