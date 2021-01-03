defmodule HealthBoardWeb.DashboardLive.Components.Section do
  use Surface.Component

  alias Phoenix.LiveView

  @doc "Disable it to avoid horizontal margin"
  prop horizontal_margin, :boolean, default: true

  @doc "The section content"
  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{
      "uk-section",
      "uk-section-xsmall",
      "uk-margin-left": @horizontal_margin,
      "uk-margin-right": @horizontal_margin
    }}>
      <slot />
    </div>
    """
  end
end
