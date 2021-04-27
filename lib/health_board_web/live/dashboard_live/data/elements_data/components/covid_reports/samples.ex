defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.CovidReports.Samples do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Charts, Math}

  @label "Testes"

  @fs_daily_positive_param "fs_daily_positive_samples"
  @fs_daily_discarded_param "fs_daily_discarded_samples"
  @sars_daily_param "sars_daily_samples"

  @spec daily_epicurve(map, map) :: {:ok, tuple} | :error
  def daily_epicurve(data, params) do
    with {:ok, fs_positive} <- Components.fetch_data(data, params, @fs_daily_positive_param),
         {:ok, fs_discarded} <- Components.fetch_data(data, params, @fs_daily_discarded_param),
         {:ok, sars} <- Components.fetch_data(data, params, @sars_daily_param),
         {:ok, from_date} <- Components.fetch_data(data, params, "from_date"),
         {:ok, to_date} <- Components.fetch_data(data, params, "to_date"),
         date_range <- Date.range(from_date, to_date),
         {:ok, datasets} <- daily_epicurve_data(fs_positive, fs_discarded, sars, date_range) do
      datasets
      |> Charts.line(Enum.to_list(date_range), show_legends?: true)
      |> Components.emit_and_hook("chart_data")
    end
  end

  defp daily_epicurve_data(fs_positive, fs_discarded, sars, date_range) do
    []
    |> fs_daily_epicurve_dataset(fs_positive, fs_discarded, date_range)
    |> sars_daily_epicurve_dataset(sars, date_range)
    |> case do
      [_ | _] = datasets -> {:ok, Enum.map(datasets, &Components.smooth_line/1)}
      _datasets -> :error
    end
  end

  defp fs_daily_epicurve_dataset(datasets, positive, discarded, date_range) do
    case {positive, discarded} do
      {[_, _ | _], [_, _ | _]} ->
        positive = Enum.sort(positive, &(Date.compare(&1.date, &2.date) != :gt))
        discarded = Enum.sort(discarded, &(Date.compare(&1.date, &2.date) != :gt))
        {data, _positive, _discarded} = Enum.reduce(date_range, {[], positive, discarded}, &fs_date_samples/2)

        case data do
          [_, _ | _] ->
            data = Enum.reverse(data)

            index = 0
            label = "#{@label} (SG/COVID)"
            options = [colorize: :border, index: index + 10, border_width: 2, point_radius: 1]

            moving_average_dataset =
              data
              |> Math.moving_average()
              |> Charts.line_dataset("Média móvel de 7 dias de #{label}", Keyword.put(options, :index, index))

            dataset = Charts.line_dataset(data, label, Keyword.put(options, :hidden, true))

            [moving_average_dataset, dataset | datasets]

          _list ->
            datasets
        end

      _tuple ->
        datasets
    end
  end

  defp fs_date_samples(date, {result, positive, discarded}) do
    if Enum.any?(positive) and Enum.any?(discarded) do
      [%{date: positive_date, total: positive_total} | positive_tail] = positive

      case Date.compare(date, positive_date) do
        :eq -> fs_compare_discarded(date, result, positive_total, positive_tail, discarded)
        :lt -> {[0 | result], positive, discarded}
        :gt -> fs_date_samples(date, {result, positive_tail, discarded})
      end
    else
      {[0 | result], [], []}
    end
  end

  defp fs_compare_discarded(date, result, positive_total, positive_tail, discarded) do
    if Enum.any?(discarded) do
      [%{date: discarded_date, total: discarded_total} | discarded_tail] = discarded

      case Date.compare(date, discarded_date) do
        :eq -> {[discarded_total + positive_total | result], positive_tail, discarded_tail}
        :lt -> {[0 | result], positive_tail, discarded}
        :gt -> fs_compare_discarded(date, result, positive_total, positive_tail, discarded_tail)
      end
    end
  end

  defp sars_daily_epicurve_dataset(datasets, list, date_range) do
    case list do
      [_, _ | _] ->
        list = Enum.sort(list, &(Date.compare(&1.date, &2.date) != :gt))
        {data, _list} = Enum.reduce(date_range, {[], list}, &sars_date_samples/2)
        data = Enum.reverse(data)

        index = 1
        label = "#{@label} (SRAG/COVID)"
        options = [colorize: :border, index: index + 10, border_width: 2, point_radius: 1]

        moving_average_dataset =
          data
          |> Math.moving_average()
          |> Charts.line_dataset("Média móvel de 7 dias de #{label}", Keyword.put(options, :index, index))

        dataset = Charts.line_dataset(data, label, Keyword.put(options, :hidden, true))

        [moving_average_dataset, dataset | datasets]

      _list ->
        datasets
    end
  end

  defp sars_date_samples(date, {result, list}) do
    if Enum.any?(list) do
      [%{date: record_date, total: total} | tail] = list

      case Date.compare(date, record_date) do
        :eq -> {[total | result], tail}
        :lt -> {[0 | result], list}
        :gt -> sars_date_samples(date, {result, tail})
      end
    else
      {[0 | result], []}
    end
  end
end
