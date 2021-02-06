defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.Options do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.ElementsFragments.{FiltersModal, IndicatorsModal, SourcesModal}
  alias Phoenix.LiveView

  prop element, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <IndicatorsModal data={{ @element.indicators }} id={{ @element.id }}/>

    <FiltersModal data={{ @element.filters }} id={{ @element.id }}/>

    <SourcesModal data={{ @element.sources }} id={{ @element.id }}/>
    """
  end
end
