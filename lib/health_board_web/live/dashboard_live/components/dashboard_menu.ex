defmodule HealthBoardWeb.DashboardLive.Components.DashboardMenu do
  use Surface.Component

  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop group_index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id="menu" uk-offcanvas>
      <div class="uk-offcanvas-bar">
        <button class="uk-offcanvas-close" type="button" uk-close></button>

        <h3>{{ @dashboard.name }}</h3>

        <ul class="uk-nav-default uk-nav-parent-icon" uk-nav="multiple: true">
          <li :for={{ group <- @dashboard.groups }} :if={{ group.index == @group_index }} class="uk-parent">
            <a href="">{{ group.name }}</a>

            <ul class="uk-nav-sub">
              <li :for={{ section <- group.sections }}>
                <a href={{ "##{section.id}" }}>{{ section.name }}</a>

                <ul class="uk-nav-sub">
                  <li :for={{ card  <- section.cards }}>
                    <a href={{ "##{card.id}" }}>
                      {{ card.name || card.card.name }}
                    </a>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>

        <hr>

        <ul class="uk-nav uk-nav-default">
          <li class="uk-nav-header">Outros Painéis</li>
          <li :if={{ @dashboard.id != "situation_report" }}><a href="/situation_report">Boletim epidemiológico</a></li>
          <li :if={{ @dashboard.id != "flu_syndrome" }}><a href="/flu_syndrome">Síndrome Gripal (SG)</a></li>
          <li :if={{ @dashboard.id != "sars" }}><a href="/sars">Síndrome Respiratória Aguda Grave (SRAG)</a></li>
        </ul>
      </div>
    </div>
    """
  end
end
