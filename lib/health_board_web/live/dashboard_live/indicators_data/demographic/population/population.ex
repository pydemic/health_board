defmodule HealthBoardWeb.DashboardLive.IndicatorsData.Population do
  alias HealthBoard.Contexts.Demographic.YearlyLocationsPopulations
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context YearlyLocationsPopulations

  @fields_filters ~w[person_age_group person_sex]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :population, &get_population!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  @spec get_fields(IndicatorsData.t()) :: list(atom())
  def get_fields(%{filters: filters}) do
    [Enum.find_value(filters, :total, &find_field/1)]
  end

  defp find_field({key, value}) do
    if key in @fields_filters do
      value
    else
      nil
    end
  end

  @spec get_population!(IndicatorsData.t()) :: @context.schema()
  def get_population!(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.get_by!()
  rescue
    _error -> @context.new()
  end

  @spec list_populations(IndicatorsData.t()) :: list(@context.schema())
  def list_populations(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.list_by()
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{population: population}}) do
    %{value: Map.get(population, field, 0)}
  end
end
