defmodule HealthBoardWeb.DashboardLive.ScalarCardComponent do
  use Phoenix.LiveComponent
  alias HealthBoardWeb.Cldr
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="<%= root_class @options %>">
      <div class="uk-card uk-card-hover uk-card-default">
        <div class="uk-card-header">
          <h3 class="uk-card-title"><%= format_title @payload.card.name, @options %></h3>
        </div>

        <div class="uk-card-body hb-match">
          <h2><%= format_value @payload.result.value, @options %></h2>
        </div>
      </div>
    </div>
    """
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

  defp maybe_format(value, :number), do: Cldr.Number.to_string!(value)
  defp maybe_format(value, _format), do: value

  defp maybe_add_suffix(value, nil), do: value
  defp maybe_add_suffix(value, :percent), do: "#{value} %"
  defp maybe_add_suffix(value, :permille), do: "#{value} ‰"
  defp maybe_add_suffix(value, :pcm), do: "#{value} pcm"
  defp maybe_add_suffix(value, suffix), do: "#{value} #{suffix}"
end
