defmodule HealthBoardWeb.DashboardLive.Components.Group do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, DynamicElement}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @group.id }} :let={{ data: _data }} wrapper_class="mb-5">
      <div class="py-6 lg:px-8 sm:px-6 px-4">
        <h1 class="text-2xl font-bold">
          {{ @group.name }}
        </h1>
      </div>

      <div class="grid grid-cols-1 gap-4 lg:px-8 sm:px-6 px-4">
        <DynamicElement :for={{ %{child: section} <- @group.children }} element={{ section }} />
      </div>
    </DataWrapper>
    """
  end
end
