defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData.Time do
  alias HealthBoardWeb.Helpers.{Humanize, TimeData}

  @spec date(map) :: map
  def date(params) do
    date = date_value(params["date"], params["default"])

    %{value: date, verbose_value: Humanize.date(date), options: options(params)}
  end

  @spec date_period(map) :: map
  def date_period(_params) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    %{name: "date_period", value: %{from: yesterday, to: today}, verbose_value: "19/04/2020 ~ 20/04/2020"}
  end

  @spec period(map) :: map
  def period(params) do
    type = type_value(params["period_type"], params["default_period_type"])

    period = %{
      type: type,
      from: value(type, params["period_from"], params["default_period_from"]),
      to: value(type, params["period_to"], params["default_period_to"])
    }

    %{
      value: period,
      verbose_value: Humanize.period(period),
      options: options(params)
    }
  end

  defp date_value(date, default) do
    TimeData.from_iso8601(date) || TimeData.from_date_query(default) || TimeData.today()
  end

  defp month_value(month, default) do
    TimeData.from_yearmonth_string(month) || TimeData.from_yearmonth_string(default) || TimeData.today_yearmonth()
  end

  defp options(params) do
    %{from_date: handle_from_date(params), to_date: handle_to_date(params)}
  end

  defp type_value(type, default) do
    TimeData.type_string_to_atom(type) || TimeData.type_string_to_atom(default) || :all
  end

  defp value(:all, _value, _default), do: nil
  defp value(:yearly, year, default), do: year_value(year, default)
  defp value(:monthly, month, default), do: month_value(month, default)
  defp value(:weekly, week, default), do: week_value(week, default)
  defp value(:daily, date, default), do: date_value(date, default)

  defp week_value(week, default) do
    TimeData.from_yearweek_string(week) || TimeData.from_yearweek_string(default) || TimeData.today_yearweek()
  end

  defp year_value(year, default) do
    %{year: TimeData.from_year_string(year) || TimeData.from_year_string(default) || TimeData.today_year()}
  end

  defp handle_from_date(params) do
    case params do
      %{"from_date" => from_date} -> TimeData.from_iso8601(from_date)
      %{"from_date_alias" => date_alias} -> TimeData.date_alias(TimeData.date_alias_string_to_atom(date_alias))
      _ -> TimeData.create_date(2000, 1, 1)
    end
  end

  defp handle_to_date(params) do
    case params do
      %{"to_date" => from_date} -> TimeData.from_iso8601(from_date)
      %{"to_date_alias" => date_alias} -> TimeData.date_alias(TimeData.date_alias_string_to_atom(date_alias))
      _ -> TimeData.today()
    end
  end
end
