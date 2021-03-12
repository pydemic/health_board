defmodule HealthBoardWeb.DashboardLive.Components.Population do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.ScalarCard
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec scalar(map, map) :: LiveView.Rendered.t()
  def scalar(assigns, params) do
    ~H"""
    <ScalarCard card={{ @element }} params={{ scalar_params(params) }} />
    """
  end

  defp scalar_params(params) do
    Map.merge(params, %{suffix: "residentes"})
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
