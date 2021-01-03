defmodule HealthBoardWeb.DashboardLive.Components.Tabs do
  use Surface.Component

  alias Phoenix.LiveView

  prop elements, :list, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <ul :if={{ Enum.any?(@elements) }} class="uk-child-width-expand uk-tab">
      <li
        :for={{ element <- @elements }}
        class={{ "uk-active": element.index == @index }}
        :on-click={{ "fetch_index", target: :live_view }}
        phx-value-index={{ element.index }}
      >
        <a href="">
          {{ element.name }}
        </a>
      </li>
    </ul>
    """
  end
end
