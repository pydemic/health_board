defmodule HealthBoardWeb.DashboardLive.IndicatorsData.MorbidityControlDiagram do
  alias HealthBoard.Contexts.Morbidities.WeeklyMorbiditiesCases
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context WeeklyMorbiditiesCases
  @default_context {:botulism, :residence}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :analytic)
    |> IndicatorsData.CommonData.fetch_year(2020)
    |> IndicatorsData.CommonData.fetch_week_period()
    |> IndicatorsData.CommonData.fetch_location()
    |> IndicatorsData.exec_and_put(:extra, :cases, &list_cases/1)
    |> IndicatorsData.exec_and_put(:extra, :labels, &get_labels/1)
    |> IndicatorsData.exec_and_put(:result, &get_result/1)
    |> IndicatorsData.emit_data(:chart, :combo)
  end

  @spec get_context(IndicatorsData.t(), {atom(), atom()}) :: integer()
  def get_context(%{filters: filters}, default_context \\ @default_context) do
    {default_disease_context, default_location_context} = default_context
    location_context = Map.get(filters, "morbidities_location_context", default_location_context)
    @context.context(default_disease_context, location_context)
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

  defp get_labels(%{extra: %{week_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_result(%{extra: %{cases: cases, labels: labels}}) do
    bar_data = Enum.map(labels, &get_bar_data(cases, &1))

    cases = Enum.map(cases, & &1.cases)

    quartile1 = Statistics.percentile(cases, 25)
    quartile2 = Statistics.percentile(cases, 50)
    quartile3 = Statistics.percentile(cases, 75)

    [
      %{
        type: "line",
        label: "Casos na semana",
        backgroundColor: "#445",
        borderColor: "#445",
        pointRadius: 2,
        borderWidth: 3,
        fill: false,
        data: bar_data
      },
      %{
        type: "line",
        label: "Limite inferior do canal endêmico",
        backgroundColor: "#6dac6d",
        borderColor: "#6dac6d",
        borderWidth: 2,
        pointRadius: 0,
        data: Enum.map(labels, fn _label -> quartile1 end)
      },
      %{
        type: "line",
        fill: "end",
        label: "Limite superior do canal endêmico",
        backgroundColor: "#e47f7f",
        borderColor: "#e47f7f",
        borderWidth: 2,
        pointRadius: 0,
        data: Enum.map(labels, fn _label -> quartile3 end)
      },
      %{
        type: "line",
        fill: false,
        label: "Índice endêmico",
        backgroundColor: "#dbcb37",
        borderColor: "#dbcb37",
        borderWidth: 2,
        pointRadius: 0,
        data: Enum.map(labels, fn _label -> quartile2 end)
      }
    ]
  end

  defp get_bar_data(cases, week) do
    Enum.find_value(cases, 0, &if(&1.week == week, do: &1.cases, else: nil))
  end
end
