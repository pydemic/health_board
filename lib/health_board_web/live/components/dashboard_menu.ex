defmodule HealthBoardWeb.LiveComponents.DashboardMenu do
  use Surface.Component

  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id="menu" uk-offcanvas>
      <div class="uk-offcanvas-bar">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h3>{{ @dashboard.name }}</h3>

        <ul :if={{ is_map(@dashboard.sections) }} class="uk-nav-default uk-nav-parent-icon" uk-nav="multiple: true">
          <li :for={{ {_section_id, section} <- @dashboard.sections }} class="uk-parent">
            <a href="#">{{ section.name }}</a>

            <ul :if={{ is_map(section.cards )}} class="uk-nav-sub">
              <li :for={{ {card_id, card} <- section.cards }}>
                <a href={{ "#to_#{card_id}" }}>
                  {{ card.name }}
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
