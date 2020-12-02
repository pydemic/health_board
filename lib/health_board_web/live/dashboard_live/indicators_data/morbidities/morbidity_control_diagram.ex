defmodule HealthBoardWeb.DashboardLive.IndicatorsData.MorbidityControlDiagram do
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.WeeklyMorbiditiesCases
  alias HealthBoardWeb.DashboardLive.IndicatorsData

  @context WeeklyMorbiditiesCases
  @default_context {:botulism, :residence}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> struct(group: :analytic)
    |> IndicatorsData.exec_and_put(:extra, :control_mode, &get_control_mode/1)
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
  def list_cases(%{modifiers: modifiers, extra: %{control_mode: control_mode}}) do
    case control_mode do
      :moving_average -> @context.list_by(Enum.to_list(Map.delete(modifiers, :year)))
      _quartile -> @context.list_by(Enum.to_list(modifiers))
    end
  end

  defp get_labels(%{extra: %{week_period: [from, to]}}) do
    from
    |> Range.new(to)
    |> Enum.to_list()
  end

  defp get_control_mode(%{modifiers: modifiers}) do
    Map.get(modifiers, "control_diagram_mode", :moving_average)
  end

  defp get_result(%{extra: %{cases: cases, labels: labels, control_mode: :quartile}}) do
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

  # defp get_result(%{extra: %{control_mode: :quartile}} = indicators_data) do
  #   %{extra: %{cases: cases, labels: labels}, modifiers: %{context: context, location_id: location_id}} =
  #     indicators_data

  #   current_year_cases = Enum.filter(cases, &(&1.year == 2020))
  #   bar_data = Enum.map(labels, &get_bar_data(current_year_cases, &1))

  #   %{from_year: from_year, to_year: to_year, from_week: from_week} =
  #     DataPeriods.get_by!(context: context, location_id: location_id)

  #   {lower, middle, upper} =
  #     for year <- from_year..to_year, week <- labels do
  #       if year < from_year or (year == from_year and week < from_week) do
  #         nil
  #       else
  #         %{week: week, cases: cases} =
  #           Enum.find(cases, %{week: week, cases: 0}, &(&1.year == year and &1.week == week))

  #         %{week: week, value: cases}
  #       end
  #     end
  #     |> Enum.reject(&is_nil/1)
  #     |> Enum.group_by(& &1.week, & &1.value)
  #     |> Enum.map(&calculate_quartile/1)
  #     |> Enum.reverse()
  #     |> Enum.reduce({[], [], []}, &ungroup_boundaries/2)

  #   [
  #     %{
  #       type: "line",
  #       label: "Casos na semana",
  #       backgroundColor: "#445",
  #       borderColor: "#445",
  #       pointRadius: 2,
  #       borderWidth: 3,
  #       fill: false,
  #       data: bar_data
  #     },
  #     %{
  #       type: "line",
  #       label: "Limite inferior do canal endêmico",
  #       backgroundColor: "#6dac6d",
  #       borderColor: "#6dac6d",
  #       borderWidth: 2,
  #       pointRadius: 0,
  #       data: lower
  #     },
  #     %{
  #       type: "line",
  #       fill: "end",
  #       label: "Limite superior do canal endêmico",
  #       backgroundColor: "#e47f7f",
  #       borderColor: "#e47f7f",
  #       borderWidth: 2,
  #       pointRadius: 0,
  #       data: upper
  #     },
  #     %{
  #       type: "line",
  #       fill: false,
  #       label: "Índice endêmico",
  #       backgroundColor: "#dbcb37",
  #       borderColor: "#dbcb37",
  #       borderWidth: 2,
  #       pointRadius: 0,
  #       data: middle
  #     }
  #   ]
  # end

  defp get_result(%{extra: %{control_mode: :moving_average}} = indicators_data) do
    %{extra: %{cases: cases, labels: labels}, modifiers: %{context: context, location_id: location_id}} =
      indicators_data

    {lower, middle, upper} = get_moving_average_boundaries(cases, labels, context, location_id)

    cases = Enum.filter(cases, &(&1.year == 2020))

    [
      %{
        type: "line",
        label: "Casos na semana",
        backgroundColor: "#445",
        borderColor: "#445",
        pointRadius: 2,
        borderWidth: 3,
        fill: false,
        data: Enum.map(labels, &get_bar_data(cases, &1))
      },
      %{
        type: "line",
        label: "Limite inferior do canal endêmico",
        backgroundColor: "#6dac6d",
        borderColor: "#6dac6d",
        borderWidth: 2,
        pointRadius: 0,
        data: lower
      },
      %{
        type: "line",
        fill: "end",
        label: "Limite superior do canal endêmico",
        backgroundColor: "#e47f7f",
        borderColor: "#e47f7f",
        borderWidth: 2,
        pointRadius: 0,
        data: upper
      },
      %{
        type: "line",
        fill: false,
        label: "Índice endêmico",
        backgroundColor: "#dbcb37",
        borderColor: "#dbcb37",
        borderWidth: 2,
        pointRadius: 0,
        data: middle
      }
    ]
  end

  defp get_moving_average_boundaries(cases, weeks, context, location_id) do
    %{from_year: from_year, from_week: from_week} = DataPeriods.get_by!(context: context, location_id: location_id)

    year_week_cases =
      for year <- from_year..2020, week <- weeks do
        if year < from_year or (year == from_year and week < from_week) do
          nil
        else
          %{week: week, cases: cases} =
            Enum.find(cases, %{week: week, cases: 0}, &(&1.year == year and &1.week == week))

          %{week: week, value: cases}
        end
      end
      |> Enum.reject(&is_nil/1)

    offset_1_cases = [nil] ++ year_week_cases
    offset_2_cases = [nil] ++ offset_1_cases
    offset_3_cases = [nil] ++ offset_2_cases
    offset_4_cases = [nil] ++ offset_3_cases
    offset_5_cases = [nil] ++ offset_4_cases
    offset_6_cases = [nil] ++ offset_5_cases

    [offset_6_cases, offset_5_cases, offset_4_cases, offset_3_cases, offset_2_cases, offset_1_cases, year_week_cases]
    |> Enum.zip()
    |> Enum.map(&calculate_moving_average/1)
    |> Enum.group_by(& &1.week, & &1.value)
    |> Enum.map(&calculate_moving_average_quartile/1)
    |> Enum.reverse()
    |> Enum.reduce({[], [], []}, &ungroup_boundaries/2)
  end

  defp calculate_moving_average(data) do
    case data do
      {nil, nil, nil, nil, nil, nil, c1} -> %{week: c1.week, value: calculate_average([c1])}
      {nil, nil, nil, nil, nil, c2, c1} -> %{week: c1.week, value: calculate_average([c2, c1])}
      {nil, nil, nil, nil, c3, c2, c1} -> %{week: c1.week, value: calculate_average([c3, c2, c1])}
      {nil, nil, nil, c4, c3, c2, c1} -> %{week: c1.week, value: calculate_average([c4, c3, c2, c1])}
      {nil, nil, c5, c4, c3, c2, c1} -> %{week: c1.week, value: calculate_average([c5, c4, c3, c2, c1])}
      {nil, c6, c5, c4, c3, c2, c1} -> %{week: c1.week, value: calculate_average([c6, c5, c4, c3, c2, c1])}
      {c7, c6, c5, c4, c3, c2, c1} -> %{week: c1.week, value: calculate_average([c7, c6, c5, c4, c3, c2, c1])}
    end
  end

  defp calculate_average(cases_list) do
    length = Enum.count(cases_list)
    Enum.reduce(cases_list, 0.0, &(&1.value + &2)) / length
  end

  defp calculate_moving_average_quartile({_week, moving_averages}) do
    {
      Statistics.percentile(moving_averages, 25),
      Statistics.percentile(moving_averages, 50),
      Statistics.percentile(moving_averages, 75)
    }
  end

  defp ungroup_boundaries({q1, q2, q3}, {l1, l2, l3}) do
    {
      [q1] ++ l1,
      [q2] ++ l2,
      [q3] ++ l3
    }
  end

  defp get_bar_data(cases, week) do
    Enum.find_value(cases, 0, &if(&1.week == week, do: &1.cases, else: nil))
  end
end
