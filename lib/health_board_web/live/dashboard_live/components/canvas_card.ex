defmodule HealthBoardWeb.DashboardLive.CanvasCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="<%= root_class @options %>">
      <div class="uk-card uk-card-hover uk-card-default">
        <div class="uk-card-header">
          <h3 class="uk-card-title"><%= @payload.card.name %></h3>
        </div>

        <div class="uk-card-body hb-card-body <%= match_group @options %>">
          <canvas id="<%= @id %>" height="400" phx-hook="Chart"></canvas>
        </div>
      </div>
    </div>
    """
  end

  defp root_class(options) do
    []
    |> add_width(options[:width_l] || 2, "l")
    |> add_width(options[:width_m] || 1, "m")
    |> Enum.join(" ")
  end

  defp add_width(class, value, scale), do: ["uk-width-1-#{value}@#{scale}"] ++ class

  defp match_group(options) do
    case options[:match_group] do
      nil -> "hb-match"
      value -> "hb-match-#{value}"
    end
  end
end
