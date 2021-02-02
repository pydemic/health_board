defmodule HealthBoardWeb.DashboardLive.Components.Section do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, DynamicElement, ElementsFragments}
  alias Phoenix.LiveView

  prop section, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @section.id }} :let={{ data: _data }} wrapper_class="border-2 border-gray-100 rounded-lg mb-6">
      <div class="mx-auto py-5 px-4 sm:px-6 lg:px-8">
        <h1 class="text-xl font-bold leading-tight text-gray-900 mb-2">
          {{ @section.name }}
        </h1>

        <ElementsFragments.FiltersTags element={{ @section }} />
      </div>

      <div class="pb-5 px-4 sm:px-6 lg:px-8 grid md:grid-cols-3 place-items-stretch gap-4">
        <DynamicElement :for={{ %{child: card} <- @section.children }} element={{ card }} />
      </div>
    </DataWrapper>
    """
  end
end
