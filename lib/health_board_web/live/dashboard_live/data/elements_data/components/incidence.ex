defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Incidence do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Charts, Humanize, Math, TimeData}

  @spec daily_epicurve(map, map) :: {:ok, {:emit_and_hook, {map, String.t(), map}}} | :ok
  def daily_epicurve(data, params) do
    case Components.fetch_data(data, params, "daily_incidence") do
      {:ok, incidence_list} -> {:ok, {:emit_and_hook, daily_epicurve_data(incidence_list)}}
      :error -> :ok
    end
  end

  defp daily_epicurve_data(incidence_list) do
    today = TimeData.today()
    {from, to} = Enum.reduce(incidence_list, {today, today}, &date_min_and_max/2)
    date_range = Date.range(from, to)
    incidence_list = Enum.map(date_range, &fetch_daily_epicurve_data(&1, incidence_list))
    trend = Math.moving_average(incidence_list)

    data =
      [
        %{
          type: "line",
          label: "Tendência (Média móvel de 7 dias)",
          backgroundColor: "#000",
          borderColor: "#000",
          borderWidth: 2,
          pointRadius: 1,
          fill: false,
          data: trend
        },
        %{
          type: "bar",
          label: "Incidência",
          backgroundColor: "rgba(54, 162, 235, 0.2)",
          borderColor: "#36a2eb",
          pointRadius: 2,
          borderWidth: 3,
          fill: false,
          data: incidence_list
        }
      ]
      |> Charts.combo("Data", Enum.to_list(date_range))

    {%{ready?: true}, "chart_data", data}
  end

  defp date_min_and_max(%{date: date}, {from, to}) do
    {date_min(date, from), date_max(date, to)}
  end

  defp date_min(d1, d2) do
    if Date.compare(d1, d2) == :gt do
      d2
    else
      d1
    end
  end

  defp date_max(d1, d2) do
    if Date.compare(d1, d2) == :lt do
      d2
    else
      d1
    end
  end

  defp fetch_daily_epicurve_data(date, incidence_list) do
    Enum.find_value(incidence_list, 0, &if(Date.compare(&1.date, date) == :eq, do: &1.total))
  end

  @spec monthly_chart(map, map) :: {:ok, {:emit_and_hook, {map, String.t(), map}}}
  def monthly_chart(data, params) do
    case Components.fetch_data(data, params, "monthly_incidence") do
      {:ok, incidence_list} -> {:ok, {:emit_and_hook, monthly_chart_data(incidence_list)}}
      :error -> :ok
    end
  end

  defp monthly_chart_data(incidence_list) do
    months = fetch_months(incidence_list)

    months
    |> Enum.map(&fetch_monthly_chart_data(&1, incidence_list))
    |> wrap_monthly_chart(months)
  end

  defp fetch_months(incidence_list) do
    %{year: y, month: m} = TimeData.today_yearmonth()
    {{fy, fm}, {ty, tm}} = Enum.reduce(incidence_list, {{y, m}, {y, m}}, &month_min_and_max/2)

    for year <- fy..ty, month <- 1..12 do
      if (year == fy and month < fm) or (year == ty and month > tm) do
        nil
      else
        {year, month}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp month_min_and_max(%{year: year, month: month}, {{fy, fm}, {ty, tm}}) do
    {month_min(year, month, fy, fm), month_max(year, month, ty, tm)}
  end

  defp month_min(y1, m1, y2, m2) do
    cond do
      y1 > y2 -> {y2, m2}
      y1 < y2 -> {y1, m1}
      m1 > m2 -> {y2, m2}
      m1 < m2 -> {y1, m1}
      true -> {y1, m1}
    end
  end

  defp month_max(y1, m1, y2, m2) do
    cond do
      y1 < y2 -> {y2, m2}
      y1 > y2 -> {y1, m1}
      m1 < m2 -> {y2, m2}
      m1 > m2 -> {y1, m1}
      true -> {y1, m1}
    end
  end

  defp fetch_monthly_chart_data({year, month}, incidence_list) do
    Enum.find_value(incidence_list, 0, &if(&1.year == year and &1.month == month, do: &1.total))
  end

  defp wrap_monthly_chart(data, months) do
    {%{ready?: true}, "chart_data", Charts.line(data, "Incidência", Enum.map(months, fn {y, m} -> "#{y}-#{m}" end))}
  end

  @spec scalar(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def scalar(data, params) do
    {:ok, {:emit, %{value: do_scalar(data, params)}}}
  end

  defp do_scalar(data, params) do
    case Components.fetch_data(data, params, "incidence") do
      {:ok, %{total: cases}} -> Humanize.number(cases)
      :error -> nil
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def top_ten_locations_table(data, params) do
    {:ok, {:emit, do_top_ten_locations_table(data, params)}}
  end

  defp do_top_ten_locations_table(data, params) do
    case Components.fetch_data(data, params, "incidence_list") do
      {:ok, incidence_list} -> %{lines: top_ten_table_lines(incidence_list)}
      :error -> %{}
    end
  end

  defp top_ten_table_lines(incidence_list) do
    incidence_list
    |> Enum.sort(&(&1.total >= &2.total))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp top_ten_table_line(%{location: location, total: cases}) do
    %{cells: [{Humanize.location(location), %{location: location.id}}, Humanize.number(cases)]}
  end

  @spec weekly_chart(map, map) :: {:ok, {:emit_and_hook, {map, String.t(), map}}} | :ok
  def weekly_chart(data, params) do
    case Components.fetch_data(data, params, "weekly_incidence") do
      {:ok, incidence_list} -> {:ok, {:emit_and_hook, weekly_chart_data(incidence_list)}}
      :error -> :ok
    end
  end

  defp weekly_chart_data(incidence_list) do
    weeks = fetch_weeks(incidence_list)

    weeks
    |> Enum.map(&fetch_weekly_chart_data(&1, incidence_list))
    |> wrap_weekly_chart(weeks)
  end

  defp fetch_weeks(deaths_list) do
    %{year: y, week: w} = TimeData.today_yearweek()
    {{fy, fw}, {ty, tw}} = Enum.reduce(deaths_list, {{y, w}, {y, w}}, &week_min_and_max/2)

    for year <- fy..ty, week <- 1..53 do
      if (year == fy and week < fw) or (year == ty and week > tw) do
        nil
      else
        {year, week}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp week_min_and_max(%{year: year, week: week}, {{fy, fw}, {ty, tw}}) do
    {week_min(year, week, fy, fw), week_max(year, week, ty, tw)}
  end

  defp week_min(y1, w1, y2, w2) do
    cond do
      y1 > y2 -> {y2, w2}
      y1 < y2 -> {y1, w1}
      w1 > w2 -> {y2, w2}
      w1 < w2 -> {y1, w1}
      true -> {y1, w1}
    end
  end

  defp week_max(y1, w1, y2, w2) do
    cond do
      y1 < y2 -> {y2, w2}
      y1 > y2 -> {y1, w1}
      w1 < w2 -> {y2, w2}
      w1 > w2 -> {y1, w1}
      true -> {y1, w1}
    end
  end

  defp fetch_weekly_chart_data({year, week}, incidence_list) do
    Enum.find_value(incidence_list, 0, &if(&1.year == year and &1.week == week, do: &1.total))
  end

  defp wrap_weekly_chart(data, weeks) do
    {%{ready?: true}, "chart_data", Charts.line(data, "Incidência", Enum.map(weeks, fn {y, w} -> "#{y}-#{w}" end))}
  end
end
