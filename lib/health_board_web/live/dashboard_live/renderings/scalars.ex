defmodule HealthBoardWeb.DashboardLive.Renderings.Scalars do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView

  @scalar_indicators_visualizations [:population]

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    indicators_visualizations =
      assigns
      |> Map.get(:indicators_visualizations, %{})
      |> Map.take(@scalar_indicators_visualizations)

    case scalar_cards(assigns, indicators_visualizations) do
      nil -> ~L""
      cards -> grid(assigns, cards)
    end
  end

  defp grid(assigns, cards) do
    ~L"""
    <div
      class="uk-grid uk-grid-small uk-grid-match uk-text-center uk-margin-left uk-margin-right uk-animation-fade"
      uk-grid
    >
      <%= cards %>
    </div>
    """
  end

  defp scalar_cards(assigns, indicators_visualizations) do
    if Enum.any?(Map.keys(indicators_visualizations)) do
      ~L"""
      <%= for {key, data} <- indicators_visualizations do %>
        <div class="uk-width-1-3@l uk-width-1-2@m uk-align-center">
          <div class="uk-card uk-card-hover uk-card-default">
            <div class="uk-card-header">
              <h3 class="uk-card-title"><%= get_card_title(key) %></h3>
            </div>

            <div class="uk-card-body">
              <h2><%= data %></h2>
            </div>
          </div>
        </div>
      <% end %>
      """
    else
      nil
    end
  end

  defp get_card_title(:population) do
    "População Residente"
  end
end
