defmodule HealthBoardWeb.DashboardLive.Components.SituationReport do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.SituationReport.{ICURateTableCard, SummaryTableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec icu_rate_table(map, map) :: LiveView.Rendered.t()
  def icu_rate_table(assigns, params) do
    ~H"""
    <ICURateTableCard card={{ @element }} params={{ icu_rate_table_params(params) }} />
    """
  end

  defp icu_rate_table_params(params) do
    params
  end

  @spec summary_table(map, map) :: LiveView.Rendered.t()
  def summary_table(assigns, params) do
    ~H"""
    <SummaryTableCard card={{ @element }} params={{ summary_table_params(params) }} />
    """
  end

  defp summary_table_params(params) do
    params
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
