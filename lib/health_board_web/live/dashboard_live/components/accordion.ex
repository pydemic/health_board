defmodule HealthBoardWeb.DashboardLive.Components.AccordionItem do
  use Surface.Component

  alias Phoenix.LiveView

  prop open, :boolean, default: true
  prop title, :string, required: true

  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <li class={{ "uk-open": @open }}>
      <a class="uk-accordion-title" href="">{{ @title }}</a>

      <div class="uk-accordion-content">
        <slot />
      </div>
    </li>
    """
  end
end
