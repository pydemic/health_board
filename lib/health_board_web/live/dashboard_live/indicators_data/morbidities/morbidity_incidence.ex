defmodule HealthBoardWeb.DashboardLive.IndicatorsData.MorbidityIncidence do
  alias HealthBoard.Contexts.Morbidities.YearlyMorbiditiesCases
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context YearlyMorbiditiesCases
  @default_context {:botulism, :residence}

  @fields_filters ~w[person_race person_sex_age_group]

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :analytic)
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :all_cases, &list_cases/1)
    |> IndicatorsData.exec_and_put(:data, :data_period, &get_data_period/1)
    |> IndicatorsData.CommonData.fetch_year()
    |> IndicatorsData.exec_and_put(:extra, :cases, &get_cases!/1)
    |> IndicatorsData.exec_and_put(:data, :fields, &get_fields/1)
    |> IndicatorsData.exec_and_put(:data, :average, &get_average/1)
    |> IndicatorsData.exec_and_put(:data, :border_color, &get_border_color/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
  end

  @spec get_average(IndicatorsData.t()) :: integer()
  def get_average(%{extra: %{all_cases: all_cases, cases: %{cases: current_cases} = cases}}) do
    total_cases = Enum.reduce(all_cases, 0, &calculate_total_cases(&1, &2, cases))
    years = Enum.count(all_cases) - 1

    if years == 0 do
      current_cases
    else
      div(total_cases, years)
    end
  end

  @spec get_border_color(IndicatorsData.t()) :: String.t()
  def get_border_color(%{data: %{average: average}, extra: %{cases: %{cases: cases}}}) do
    cond do
      cases > average -> "danger"
      cases == average and cases != 0 -> "warning"
      cases < average -> "success"
      true -> "disabled"
    end
  end

  defp calculate_total_cases(%{id: id1, cases: cases1}, total, %{id: id2}) do
    if id1 == id2 do
      total
    else
      total + cases1
    end
  end

  @spec get_context(IndicatorsData.t(), {atom(), atom()}) :: integer()
  def get_context(%{filters: filters}, default_context \\ @default_context) do
    {default_disease_context, default_location_context} = default_context
    location_context = Map.get(filters, "morbidities_location_context", default_location_context)
    @context.context(default_disease_context, location_context)
  end

  @spec get_data_period(IndicatorsData.t()) :: DataPeriods.schema()
  def get_data_period(%{modifiers: %{location_id: location_id, context: context}}) do
    DataPeriods.get_by!(context: context, location_id: location_id)
  rescue
    _error -> DataPeriods.new()
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
