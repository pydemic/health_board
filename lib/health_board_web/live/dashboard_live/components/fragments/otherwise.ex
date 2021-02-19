defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise do
  use Surface.Component
  alias Phoenix.LiveView

  prop condition, :boolean, required: true
  prop wrapper_class, :css_class
  prop extra_true_class, :css_class
  prop extra_false_class, :css_class
  prop true_title, :string
  prop false_title, :string

  slot default, required: true
  slot otherwise, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :if={{ @condition }} class={{ @wrapper_class, @extra_true_class }} title={{ @true_title }}>
      <slot/>
    </div>
    <div :if={{ not @condition }} class={{ @wrapper_class, @extra_false_class }} title={{ @false_title }}>
      <slot name="otherwise"/>
    </div>
    """
  end
end
