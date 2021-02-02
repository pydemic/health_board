defmodule HealthBoardWeb.DashboardLive.Components.Element do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{Dashboard, Group, Section}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec dashboard(map, map) :: LiveView.Rendered.t()
  def dashboard(assigns, params) do
    ~H"""
    <Dashboard dashboard={{ @element }} params={{ params }} />
    """
  end

  @spec group(map, map) :: LiveView.Rendered.t()
  def group(assigns, params) do
    ~H"""
    <Group group={{ @element }} params={{ params }} />
    """
  end

  @spec section(map, map) :: LiveView.Rendered.t()
  def section(assigns, params) do
    ~H"""
    <Section section={{ @element }} params={{ params }} />
    """
  end

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      Do not use this function.
    </div>
    """
  end
end
