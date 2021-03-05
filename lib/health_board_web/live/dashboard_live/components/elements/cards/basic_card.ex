defmodule HealthBoardWeb.DashboardLive.Components.BasicCard do
  use Surface.Component
  alias Phoenix.LiveView

  prop name, :string, default: ""

  prop show_body, :boolean, default: true

  prop show_footer, :boolean, default: false

  prop wrapper_class, :css_class,
    default:
      "flex flex-col place-content-evenly self-center border rounded-lg border-opacity-20 border-hb-ca dark:border-hb-ca-dark"

  prop extra_wrapper_class, :css_class

  prop header_class, :css_class, default: "px-5 py-2 font-bold text-center"

  prop body_class, :css_class,
    default: "flex-grow text-center border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark"

  prop extra_body_class, :css_class

  slot default
  slot footer, required: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ @wrapper_class, @extra_wrapper_class }}>
      <div class={{ @header_class }}>
        {{ @name }}
      </div>

      <div :if={{ @show_body }} class={{ @body_class, @extra_body_class }}>
        <slot />
      </div>

      <div :if={{ @show_footer }} class="border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
        <slot name="footer"/>
      </div>
    </div>
    """
  end
end
