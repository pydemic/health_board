defmodule HealthBoardWeb.DashboardLive.Components.Hospitalizations do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{ChartCard, ScalarCard, TableCard}
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec daily_epicurve(map, map) :: LiveView.Rendered.t()
  def daily_epicurve(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ daily_epicurve_params(params) }} />
    """
  end

  defp daily_epicurve_params(params) do
    params
  end

  @spec per_age_gender(map, map) :: LiveView.Rendered.t()
  def per_age_gender(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ per_age_gender_params(params) }} />
    """
  end

  defp per_age_gender_params(params) do
    params
  end

  @spec per_comorbidity(map, map) :: LiveView.Rendered.t()
  def per_comorbidity(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ per_comorbidity_params(params) }} />
    """
  end

  defp per_comorbidity_params(params) do
    params
  end

  @spec per_race(map, map) :: LiveView.Rendered.t()
  def per_race(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ per_race_params(params) }} />
    """
  end

  defp per_race_params(params) do
    params
  end

  @spec per_symptom(map, map) :: LiveView.Rendered.t()
  def per_symptom(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ per_symptom_params(params) }} />
    """
  end

  defp per_symptom_params(params) do
    params
  end

  @spec scalar(map, map) :: LiveView.Rendered.t()
  def scalar(assigns, params) do
    ~H"""
    <ScalarCard card={{ @element }} params={{ scalar_params(params) }} />
    """
  end

  defp scalar_params(params) do
    Map.merge(params, %{suffix: "internações"})
  end

  @spec top_ten_locations_table(map, map) :: LiveView.Rendered.t()
  def top_ten_locations_table(assigns, params) do
    ~H"""
    <TableCard card={{ @element }} params={{ top_ten_locations_table_params(params) }} />
    """
  end

  defp top_ten_locations_table_params(params) do
    Map.merge(params, %{slice: 0..9, with_index: true, headers: ~w[Local Internações]})
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