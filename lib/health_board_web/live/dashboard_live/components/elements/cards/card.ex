defmodule HealthBoardWeb.DashboardLive.Components.Card do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.DataWrapper
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Loading
  alias HealthBoardWeb.DashboardLive.Components.Card.Options
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  prop wrapper_class, :css_class,
    default:
      "flex flex-col place-content-evenly self-center border rounded-lg border-opacity-20 border-hb-ca dark:border-hb-ca-dark"

  prop extra_wrapper_class, :css_class

  prop header_class, :css_class, default: "px-5 py-2 font-bold text-center"

  prop body_class, :css_class,
    default: "flex-grow px-5 py-2 text-center border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark"

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
        <Loading />
      </div>

      <div :if={{ @element.show_options }} class="border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
        <Options :if={{ @element.show_options }} id={{ "options_#{@element.id}" }} element={{ @element }} params={{ @params }} />
      </div>
    </DataWrapper>
    """
  end
end
