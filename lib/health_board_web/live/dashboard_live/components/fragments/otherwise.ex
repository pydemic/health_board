defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise do
  use Surface.Component
  alias Phoenix.LiveView

  prop condition, :boolean, required: true
  prop wrapper_class, :css_class
  prop extra_true_class, :css_class
  prop extra_false_class, :css_class

  slot default, required: true
  slot otherwise, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :if={{ @condition }} class={{ @wrapper_class, @extra_true_class }}>
      <slot/>
    </div>
    <div :if={{ not @condition }} class={{ @wrapper_class, @extra_false_class }}>
      <slot name="otherwise"/>
    </div>
    """
  end
end
