defmodule HealthBoardWeb.DashboardLive.Components.CardHeaderTitle do
  use Surface.Component, slot: "header"

  alias Phoenix.LiveView

  @doc "The card title"
  prop title, :string

  @doc "A link"
  prop link, :string

  @doc "The card header border color"
  prop border_color, :atom, values: [:success, :warning, :danger, :disabled]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-card-header", "hb-border": @border_color, "hb-border-bottom": @border_color, "hb-border-#{@border_color}": @border_color }}>
      <h3 class="uk-card-title uk-text-middle">
        <a :if={{ @link }} class={{ "hb-title-link" }} href={{ @link}}>{{ @title }}</a>
        <span :if={{ is_nil(@link) }}>{{ @title }}</span>
      </h3>
    </div>
    """
  end
end
