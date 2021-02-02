defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.Card do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, ElementsFragments, Fragments}
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  prop wrapper_class, :css_class, default: "flex flex-col place-content-evenly rounded-lg shadow-md"
  prop header_class, :css_class, default: "px-6 py-4 border-b border-gray-200 font-bold text-center"
  prop body_class, :css_class, default: "p-6 border-b border-gray-200 text-center"
  prop footer_class, :css_class, default: "px-6 py-2 flex justify-evenly content-center"

  slot default, props: [:data]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @element.id }} :let={{ data: data }} wrapper_class={{ @wrapper_class }}>
      <div class={{ @header_class }}>
        {{ @element.name }}
      </div>

      <div :if={{ Enum.any?(data) }} class={{ @body_class }}>
        <slot :props={{ data: data }} />
      </div>

      <div :if={{ Enum.empty?(data) }} class={{ @body_class }}>
        <Fragments.Loading />
      </div>

      <div class={{ @footer_class }}>
        <ElementsFragments.Options element={{ @element }} params={{ @params }} />
      </div>
    </DataWrapper>
    """
  end
end
