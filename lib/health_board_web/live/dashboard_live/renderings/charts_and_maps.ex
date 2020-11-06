defmodule HealthBoardWeb.DashboardLive.Renderings.ChartsAndMaps do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView

  @charts_and_maps_indicators_visualizations [:population_growth, :population_per_age_group, :population_per_sex]

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    indicators_visualizations =
      assigns
      |> Map.get(:indicators_visualizations, %{})
      |> Map.take(@charts_and_maps_indicators_visualizations)

    case charts_and_maps_cards(assigns, indicators_visualizations) do
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

  defp charts_and_maps_cards(assigns, indicators_visualizations) do
    if Enum.any?(Map.keys(indicators_visualizations)) do
      ~L"""
      <%= for {key, _data} <- indicators_visualizations do %>
        <div class="uk-width-1-2@l">
          <div class="uk-card uk-card-hover uk-card-default" phx-update="ignore">
            <div class="uk-card-header">
              <h3 class="uk-card-title uk-text-center"><%= get_card_title key %></h3>
            </div>
            <div class="uk-card-body" phx-update="ignore">
              <canvas id="<%= Atom.to_string(key) %>" height="260"></canvas>
            </div>
          </div>
        </div>
      <% end %>
      """
    else
      nil
    end
  end

  defp get_card_title(key) do
    case key do
      :population_growth -> "Crescimento populacional"
      :population_per_age_group -> "Pirâmidade etária"
      :population_per_sex -> "Razão de sexo"
    end
  end
end
