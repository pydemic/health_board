defmodule HealthBoardWeb.DashboardLive.IndicatorsData.Births do
  alias HealthBoard.Contexts.Demographic.YearlyLocationsBirths
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context YearlyLocationsBirths

  @default_birth_year 2018
  @minimum_year 2000
  @default_location_context @context.resident_location_context()

  @fields_filters [
    "births_child_mass",
    "births_child_masses",
    "births_child_sex",
    "births_deliveries",
    "births_delivery",
    "births_gestation_duration",
    "births_gestation_durations",
    "births_location",
    "births_locations",
    "births_mother_age",
    "births_mother_ages",
    "births_prenatal_consultation",
    "births_prenatal_consultations"
  ]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :demographic)
    |> IndicatorsData.CommonData.fetch_year(&subtract_year_by_one/1)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:modifiers, :location_context, &get_location_context/1)
    |> IndicatorsData.exec_and_put(:extra, :births, &get_births!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &get_fields/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  @spec get_births!(IndicatorsData.t()) :: @context.schema()
  def get_births!(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.get_by!()
  rescue
    _error -> @context.new()
  end

  @spec list_births(IndicatorsData.t()) :: list(@context.schema())
  def list_births(%{modifiers: modifiers}) do
    modifiers
    |> Enum.to_list()
    |> @context.list_by()
  end

  @spec get_location_context(IndicatorsData.t(), integer()) :: IndicatorsData.t()
  def get_location_context(%{filters: filters}, default \\ @default_location_context) do
    Map.get(filters, "births_location_context", default)
  end

  @spec get_fields(IndicatorsData.t()) :: list(atom())
  def get_fields(%{filters: filters}) do
    [Enum.find_value(filters, :births, &find_field/1)]
  end

  defp find_field({key, value}) do
    if key in @fields_filters do
      value
    else
      nil
    end
  end

  @spec subtract_year_by_one(integer()) :: integer()
  def subtract_year_by_one(year) do
    if is_nil(year) do
      @default_birth_year
    else
      if year > @minimum_year do
        year - 1
      else
        @minimum_year
      end
    end
  end

  defp get_result(%{data: %{fields: [field]}, extra: %{births: births}}) do
    %{value: Map.get(births, field, 0)}
  end
end
