defmodule HealthBoardWeb.DashboardLive.ScalarCardBuilder do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2, live_component: 3]
  alias HealthBoardWeb.Cldr
  alias HealthBoardWeb.DashboardLive.CardComponent
  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map(), map(), keyword()) :: LiveView.Component.t()
  def render(assigns, payload, options) do
    live_component(assigns.socket, CardComponent, build_card(assigns, payload, options))
  end

  defp build_card(assigns, payload, options) do
    %{id: id, card: card, result: result} = payload

    [
      id: id,
      title: card.name,
      body: body(assigns, result, options),
      footer: footer(assigns, id),
      extras: extras(assigns, id, card),
      options: [footer_class: ["uk-hidden-hover"]] ++ options
    ]
  end

  defp body(assigns, result, options) do
    ~L"""
    <h2><%= format_value(result.value, options) %></h2>
    """
  end

  defp format_value(value, options) do
    value
    |> maybe_format(options[:format] || :number)
    |> maybe_add_suffix(options[:suffix])
  end

  defp maybe_format(value, :number), do: Cldr.Number.to_string!(value)
  defp maybe_format(value, _format), do: value

  defp maybe_add_suffix(value, nil), do: value
  defp maybe_add_suffix(value, :percent), do: "#{value} %"
  defp maybe_add_suffix(value, :permille), do: "#{value} ‰"
  defp maybe_add_suffix(value, :pcm), do: "#{value} pcm"
  defp maybe_add_suffix(value, suffix), do: "#{value} #{suffix}"

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
