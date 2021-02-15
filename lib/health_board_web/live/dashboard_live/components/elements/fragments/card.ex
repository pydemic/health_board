defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.Card do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, ElementsFragments, Fragments}
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  prop wrapper_class, :css_class, default: "flex flex-col place-content-evenly border rounded-lg shadow-md self-center"
  prop extra_wrapper_class, :css_class, default: ""
  prop header_class, :css_class, default: "px-6 py-4 border-b border-gray-200 font-bold text-center"
  prop body_class, :css_class, default: "p-6 border-b border-gray-200 text-center"

  slot default, props: [:data]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @element.id }} :let={{ data: data }} wrapper_class={{ @wrapper_class, @extra_wrapper_class }}>
      <div class={{ @header_class }}>
        {{ @element.name }}
      </div>

      <div :if={{ Enum.any?(data) }} class={{ @body_class }}>
        <slot :props={{ data: data }} />
      </div>

      <div :if={{ Enum.empty?(data) }} class={{ @body_class }}>
        <Fragments.Loading />
      </div>

      <ElementsFragments.Options id={{ "options_#{@element.id}" }} element={{ @element }} params={{ @params }} />
    </DataWrapper>
    """
  end
end
