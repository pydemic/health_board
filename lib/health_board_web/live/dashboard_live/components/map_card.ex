defmodule HealthBoardWeb.DashboardLive.MapCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="<%= root_class @options %>">
      <div class="uk-card uk-card-hover uk-card-default">
        <div id="<%= @id %>" class="uk-card-body hb-map hb-match uk-height-1-1" phx-hook="Map"></div>
      </div>

      <%= if @payload.data[:ranges] do %>
      <div id="<%= @id %>-modal" class="uk-flex-top" uk-modal>
        <div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical">
          <h2 class="uk-modal-title">Legenda</h2>

          <%= for %{color: color, text: text} <- @payload.data.ranges do %>
          <p class="hb-map-legend"><i style="background: <%= color %>"></i> <%= text %></p>
          <% end %>

          <button class="uk-modal-close-default" type="button" uk-close></button>
        </div>
      </div>
      <% end %>
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
end
