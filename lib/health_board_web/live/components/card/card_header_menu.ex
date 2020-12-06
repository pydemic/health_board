defmodule HealthBoardWeb.LiveComponents.CardHeaderMenu do
  use Surface.Component, slot: "header"

  alias Phoenix.LiveView

  alias HealthBoardWeb.LiveComponents.Modal

  @doc "The card title"
  prop title, :string

  @doc "A link"
  prop link, :string

  @doc "The card header border color"
  prop border_color, :atom, values: [:success, :warning, :danger, :disabled]

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-card-header", "uk-visible-toggle", "show-when-not-hover-container", "uk-transition-toggle", "hb-border": @border_color, "hb-border-bottom": @border_color, "hb-border-#{@border_color}": @border_color }}>
      <h3 class={{"uk-card-title"}}>
        <a :if={{ @link }} class={{ "hb-title-link", "show-when-not-hover" }} href={{ @link}}>{{ @title }}</a>
        <span :if={{ is_nil(@link) }}>{{ @title }}</span>
      </h3>
      <div class={{ "uk-hidden-hover", "uk-transition-slide-top" }}>
        <p>Menu</p>
        <a href="#offcanvas" uk-toggle>Open</a>
      </div>
    </div>
    """
  end
end
