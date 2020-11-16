defmodule HealthBoardWeb.DashboardLive.IndicatorsData.ViolenceIncidence do
  alias HealthBoard.Contexts.Morbidities.ViolenceYearlyCases
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context ViolenceYearlyCases
  @default_location_context @context.resident_location_context()

  @fields_filters ~w[person_age_group person_race person_sex]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :violence)
    |> IndicatorsData.CommonData.fetch_year(2018)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :cases, &get_cases!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  @spec get_fields(IndicatorsData.t()) :: list(atom())
  def get_fields(%{filters: filters}) do
    [Enum.find_value(filters, :cases, &find_field/1)]
  end

  defp find_field({key, value}) do
    if key in @fields_filters do
      value
    else
      nil
    end
  end

  @spec get_location_context(IndicatorsData.t(), integer()) :: IndicatorsData.t()
  def get_location_context(%{filters: filters}, default \\ @default_location_context) do
    Map.get(filters, "morbidities_location_context", default)
  end

  @spec get_cases!(IndicatorsData.t()) :: @context.schema()
  def get_cases!(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.get_by!()
  rescue
    _error -> @context.new()
  end

  @spec list_cases(IndicatorsData.t()) :: list(@context.schema())
  def list_cases(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.list_by()
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{cases: cases}}) do
    %{value: Map.get(cases, field, 0)}
  end
end
