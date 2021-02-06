defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise do
  use Surface.Component

  prop condition, :boolean, required: true

  slot default, required: true
  slot otherwise, required: true

  def render(assigns) do
    ~H"""
    <div :if={{ @condition }}>
      <slot/>
    </div>
    <div :if={{ not @condition }}>
      <slot name="otherwise"/>
    </div>
    """
  end
end
