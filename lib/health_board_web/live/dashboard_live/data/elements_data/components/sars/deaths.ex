defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.SARS.Deaths do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Charts, Math}

  @scalar_param "deaths"
  @daily_param "daily_#{@scalar_param}"

  @spec daily_epicurve(map, map) :: {:ok, tuple} | :error
  def daily_epicurve(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @daily_param),
         {:ok, from_date} <- Components.fetch_data(data, params, "from_date"),
         {:ok, to_date} <- Components.fetch_data(data, params, "to_date"),
         date_range <- Date.range(from_date, to_date),
         {:ok, datasets} <- daily_epicurve_data(list, date_range) do
      datasets
      |> Charts.line(Enum.to_list(date_range), show_legends?: true)
      |> Components.emit_and_hook("chart_data")
    end
  end

  defp daily_epicurve_data(list, date_range) do
    list
    |> Enum.sort(&(Date.compare(&1.date, &2.date) != :lt))
    |> Enum.reduce({[], [], [], [], [], [], [], [], [], [], [], []}, &per_virus/2)
    |> daily_epicurve_datasets(date_range)
    |> Enum.reverse()
    |> case do
      [_ | _] = datasets -> {:ok, Enum.map(datasets, &Components.smooth_line/1)}
      _datasets -> :error
    end
  end

  defp per_virus(%{total: covid, values: values, date: date}, lists) do
    covid = covid || 0
    values = [covid | parse_values(values)]
    sum = Enum.sum(values)

    if sum > 0 do
      values = [sum | values]
      [t, c, v, p1, p2, p3, p4, a, m, b, r, o] = Enum.map(values, &%{total: &1, date: date})
      {total, covid, vsr, para1, para2, para3, para4, adeno, metap, boca, rino, others} = lists

      {
        [t | total],
        [c | covid],
        [v | vsr],
        [p1 | para1],
        [p2 | para2],
        [p3 | para3],
        [p4 | para4],
        [a | adeno],
        [m | metap],
        [b | boca],
        [r | rino],
        [o | others]
      }
    else
      lists
    end
  end

  defp parse_values(list) when is_list(list), do: list
  defp parse_values(string) when is_binary(string), do: Enum.map(String.split(string, ","), &String.to_integer/1)
  defp parse_values(_result), do: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  defp daily_epicurve_datasets(data, date_range) do
    {total, covid, vsr, para1, para2, para3, para4, adeno, metap, boca, rino, others} = data

    []
    |> daily_epicurve_dataset(total, "Total", 0, date_range)
    |> daily_epicurve_dataset(covid, "SARS-CoV-2", 1, date_range)
    |> daily_epicurve_dataset(vsr, "VSR", 2, date_range)
    |> daily_epicurve_dataset(para1, "Parainfluenza 1", 3, date_range)
    |> daily_epicurve_dataset(para2, "Parainfluenza 2", 4, date_range)
    |> daily_epicurve_dataset(para3, "Parainfluenza 3", 5, date_range)
    |> daily_epicurve_dataset(para4, "Parainfluenza 4", 6, date_range)
    |> daily_epicurve_dataset(adeno, "Adenovírus", 7, date_range)
    |> daily_epicurve_dataset(metap, "Metapneumovírus", 8, date_range)
    |> daily_epicurve_dataset(boca, "Bocavírus", 9, date_range)
    |> daily_epicurve_dataset(rino, "Rinovírus", 20, date_range)
    |> daily_epicurve_dataset(others, "Outros", 21, date_range)
  end

  defp daily_epicurve_dataset(datasets, list, label, index, date_range) do
    case list do
      [_, _ | _] ->
        list = Enum.sort(list, &(Date.compare(&1.date, &2.date) != :gt))
        {data, _list} = Enum.reduce(date_range, {[], list}, &date_deaths/2)
        data = Enum.reverse(data)

        options = [colorize: :border, index: index + 10, border_width: 2, point_radius: 1]

        moving_average_dataset =
          data
          |> Math.moving_average()
          |> Charts.line_dataset("Média móvel de 7 dias (#{label})", Keyword.put(options, :index, index))

        dataset = Charts.line_dataset(data, label, Keyword.put(options, :hidden, true))

        [moving_average_dataset, dataset | datasets]

      _list ->
        datasets
    end
  end

  defp date_deaths(date, {result, list}) do
    if Enum.any?(list) do
      [%{date: record_date, total: total} | tail] = list

      case Date.compare(date, record_date) do
        :eq -> {[total | result], tail}
        :lt -> {[0 | result], list}
        :gt -> date_deaths(date, {result, tail})
      end
    else
      {[0 | result], []}
    end
  end
end
