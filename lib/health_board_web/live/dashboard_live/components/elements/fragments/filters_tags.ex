defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.FiltersTags do
  use Surface.Component
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div
      :for={{ %{title: title, verbose_value: value} <- @element.filters }}
      class="text-xs inline-flex items-center leading-sm mr-2 px-2 py-1 bg-blue-100 rounded-full"
    >
      <span class="font-bold text-blue-700">
        {{ title }}:
      </span>

      <span class="ml-2 text-blue-600">
        {{ value }}
      </span>
    </div>
    """
  end
end
