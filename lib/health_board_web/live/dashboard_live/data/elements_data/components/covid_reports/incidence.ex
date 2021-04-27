defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.CovidReports.Incidence do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Charts, Math}

  @label "Incidência"

  @scalar_param "incidence"

  @daily_param "daily_#{@scalar_param}"
  @fs_daily_param "fs_#{@daily_param}"
  @sars_daily_param "sars_#{@daily_param}"
  @sr_daily_param "sr_#{@daily_param}"

  @spec daily_epicurve(map, map) :: {:ok, tuple} | :error
  def daily_epicurve(data, params) do
    with {:ok, fs} <- Components.fetch_data(data, params, @fs_daily_param),
         {:ok, sars} <- Components.fetch_data(data, params, @sars_daily_param),
         {:ok, sr} <- Components.fetch_data(data, params, @sr_daily_param),
         {:ok, from_date} <- Components.fetch_data(data, params, "from_date"),
         {:ok, to_date} <- Components.fetch_data(data, params, "to_date"),
         date_range <- Date.range(from_date, to_date),
         {:ok, datasets} <- daily_epicurve_data(fs, sars, sr, date_range) do
      datasets
      |> Charts.line(Enum.to_list(date_range), show_legends?: true)
      |> Components.emit_and_hook("chart_data")
    end
  end

  defp daily_epicurve_data(fs, sars, sr, date_range) do
    []
    |> daily_epicurve_dataset(fs, date_range, :fs)
    |> daily_epicurve_dataset(sars, date_range, :sars)
    |> daily_epicurve_dataset(sr, date_range, :sr)
    |> case do
      [_ | _] = datasets -> {:ok, Enum.map(datasets, &Components.smooth_line/1)}
      _datasets -> :error
    end
  end

  defp daily_epicurve_dataset(datasets, list, date_range, type) do
    case list do
      [_, _ | _] ->
        list = Enum.sort(list, &(Date.compare(&1.date, &2.date) != :gt))
        {data, _list} = Enum.reduce(date_range, {[], list}, &date_incidence/2)
        data = Enum.reverse(data)

        index = index(type)
        label = label(type)
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

  defp date_incidence(date, {result, list}) do
    if Enum.any?(list) do
      [%{date: record_date, total: total} | tail] = list

      case Date.compare(date, record_date) do
        :eq -> {[total | result], tail}
        :lt -> {[0 | result], list}
        :gt -> date_incidence(date, {result, tail})
      end
    else
      {[0 | result], []}
    end
  end

  defp label(:fs), do: "#{@label} (SG/COVID)"
  defp label(:sars), do: "#{@label} (SRAG/COVID)"
  defp label(:sr), do: "#{@label} (Resumo COVID)"

  defp index(:fs), do: 0
  defp index(:sars), do: 1
  defp index(:sr), do: 2
end
