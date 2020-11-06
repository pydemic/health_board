defmodule HealthBoardWeb.DashboardLive.Renderings.Header do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    case Map.get(assigns, :dashboard) do
      nil -> ~L""
      dashboard -> title(assigns, Map.get(dashboard, :name, ""))
    end
  end

  defp title(assigns, name) do
    ~L"""
    <h2 class="uk-heading-divider uk-margin-left uk-margin-right hb-va-center">
      Painel: <%= name %>
    </h2>
    """
  end
end
