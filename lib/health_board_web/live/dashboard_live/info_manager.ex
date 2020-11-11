defmodule HealthBoardWeb.DashboardLive.InfoManager do
  alias Phoenix.LiveView
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @spec handle_info(LiveView.Socket.t(), any()) :: LiveView.Socket.t()
  def handle_info(socket, {:fetch_indicator_visualization_data, indicator_visualization, filters}) do
    case Map.get(indicator_visualization, :indicator_visualization_id) do
      "births" -> IndicatorsData.Births.fetch(socket, filters)
      "births_per_year" -> IndicatorsData.BirthsPerYear.fetch(socket, filters)
      "births_per_child_mass" -> IndicatorsData.BirthsPerChildMass.fetch(socket, filters)
      "births_per_child_sex" -> IndicatorsData.BirthsPerChildSex.fetch(socket, filters)
      "crude_birth_rate" -> IndicatorsData.CrudeBirthRate.fetch(socket, filters)
      "population" -> IndicatorsData.Population.fetch(socket, filters)
      "population_growth" -> IndicatorsData.PopulationGrowth.fetch(socket, filters)
      "population_per_age_group" -> IndicatorsData.PopulationPerAgeGroup.fetch(socket, filters)
      "population_per_sex" -> IndicatorsData.PopulationPerSex.fetch(socket, filters)
      _nil -> socket
    end
  end

  def handle_info(socket, _data) do
    socket
  end
end
