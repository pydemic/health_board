defmodule HealthBoardWeb.DashboardLive.ScalarCardComponent do
  use Phoenix.LiveComponent
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="<%= root_class @options %>">
      <div class="uk-card uk-card-hover uk-card-default<%= maybe_colorize_border @payload.data %>">
        <div class="uk-card-header<%= maybe_colorize_border @payload.data, :bottom %>">
          <h3 class="uk-card-title"><%= format_title @payload.card.name, @options %></h3>
        </div>

        <div class="uk-card-body hb-match">
          <h2><%= format_value @payload.result.value, @options %></h2>
          <%= maybe_add_dates assigns %>
        </div>
      </div>
    </div>
    """
  end

  defp maybe_colorize_border(data, position \\ nil)

  defp maybe_colorize_border(%{border_color: color}, position) do
    if is_nil(position) do
      " hb-border hb-border-color hb-#{color}"
    else
      " hb-border hb-border-#{position} hb-border-color hb-#{color}"
    end
  end

  defp maybe_colorize_border(_data, _position) do
    ""
  end

  defp maybe_add_dates(
         %{payload: %{data: %{data_period: data_period, average: average}, modifiers: modifiers}} = assigns
       ) do
    %{from_date: from_date, to_date: to_date, extraction_date: extraction_date} = data_period
    %{year: year} = modifiers

    ~L"""
    <small>Óbitos: 0</small>
    </br>
    <small>Ano: <%= year %></small>
    </br>
    <small>Média anual: <%= Humanize.number average %></small>

    <%= if not is_nil(from_date) and not is_nil(to_date) do %>
    </br>
    <small>Período dos registros: <%= from_date.year %>-<%= to_date.year %></small>
    <% end %>

    </br>
    <small>Data do último registro: <%= Humanize.date to_date %></small>
    </br>
    <small>Data de extração: <%= Humanize.date extraction_date %></small>
    """
  end

  defp maybe_add_dates(assigns) do
    ~L""
  end

  defp root_class(options) do
    []
    |> add_width(options[:width_l] || 4, "l")
    |> add_width(options[:width_m] || 2, "m")
    |> Enum.join(" ")
  end

  defp add_width(class, value, scale), do: ["uk-width-1-#{value}@#{scale}"] ++ class

  defp format_title(value, options) do
    value
    |> maybe_add_title_suffix(options[:title_suffix])
  end

  defp maybe_add_title_suffix(value, nil), do: value
  defp maybe_add_title_suffix(value, suffix), do: "#{value} - #{suffix}"

  defp format_value(value, options) do
    value
    |> maybe_format(options[:format] || :number)
    |> maybe_add_suffix(options[:suffix])
  end

  defp maybe_format(value, :number), do: Humanize.number(value)
  defp maybe_format(value, _format), do: value

  defp maybe_add_suffix(value, nil), do: value
  defp maybe_add_suffix(value, :percent), do: "#{value} %"
  defp maybe_add_suffix(value, :permille), do: "#{value} / 1000 hab."
  defp maybe_add_suffix(value, :pcm), do: "#{value} / 100 mil hab."
  defp maybe_add_suffix(value, suffix), do: "#{value} #{suffix}"
end
