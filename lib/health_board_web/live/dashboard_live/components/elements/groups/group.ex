defmodule HealthBoardWeb.DashboardLive.Components.Group do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, DynamicElement}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @group.id }} :let={{ data: _data }}>
      <div class="mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <h1 class="text-2xl font-bold leading-tight text-gray-900">
          {{ @group.name }}
        </h1>
      </div>

      <div class="px-4 sm:px-6 lg:px-8">
        <DynamicElement :for={{ %{child: section} <- @group.children }} element={{ section }} />
      </div>
    </DataWrapper>
    """
  end
end
