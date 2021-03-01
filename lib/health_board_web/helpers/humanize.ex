defmodule HealthBoardWeb.Helpers.Humanize do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Cldr

  @spec location(Locations.schema() | nil, keyword) :: String.t()
  def location(location, _options \\ []) do
    case location do
      %{verbose_name: name} when is_binary(name) -> name
      _location -> "N/A"
    end
  end

  @spec number(integer | float | Decimal.t() | nil, keyword) :: String.t()
  def number(number, options \\ []) do
    if is_nil(number) do
      "N/A"
    else
      options = if is_float(number), do: Keyword.put_new(options, :fractional_digits, 1), else: options

      case Cldr.Number.to_string(number, options) do
        {:ok, humanized_number} -> humanized_number
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec date(Date.t() | nil) :: String.t()
  def date(date) do
    if is_nil(date) do
      "N/A"
    else
      case Cldr.Date.to_string(date, format: :long) do
        {:ok, humanized_date} -> humanized_date
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec date_period(map | nil) :: String.t()
  def date_period(period) do
    if is_map(period) do
      case {period[:from], period[:to]} do
        {nil, nil} -> "N/A"
        {date, date} -> date(date)
        {nil, date} -> date(date)
        {date, nil} -> date(date)
        {from, to} -> "#{date(from)} ~ #{date(to)}"
      end
    else
      "N/A"
    end
  end

  @spec date_time(DateTime.t() | nil) :: String.t()
  def date_time(date_time) do
    if is_nil(date_time) do
      "N/A"
    else
      case Cldr.DateTime.to_string(date_time) do
        {:ok, humanized_date_time} -> humanized_date_time
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec month(map | nil) :: String.t()
  def month(month) do
    case month do
      %{year: year, month: month} ->
        case Cldr.DateTime.to_string(Date.from_erl!({year, month, 1}), format: :y_mmm) do
          {:ok, humanized_month} -> humanized_month
          {:error, _reason} -> "N/A"
        end

      _month ->
        "N/A"
    end
  end

  @spec month_period(map | nil) :: String.t()
  def month_period(period) do
    if is_map(period) do
      case {period[:from], period[:to]} do
        {nil, nil} -> "N/A"
        {month, month} -> month(month)
        {nil, month} -> month(month)
        {month, nil} -> month(month)
        {from, to} -> "#{month(from)} ~ #{month(to)}"
      end
    else
      "N/A"
    end
  end

  @spec period(map | nil) :: String.t()
  def period(period) do
    case period[:type] do
      :all -> "Todo o período"
      :yearly -> year_period(period)
      :monthly -> month_period(period)
      :weekly -> week_period(period)
      :daily -> date_period(period)
      _type -> "N/A"
    end
  end

  @spec week(map | nil) :: String.t()
  def week(week) do
    case week do
      %{year: year, week: week} -> "Semana #{week} de #{year}"
      _week -> "N/A"
    end
  end

  @spec week_period(map | nil) :: String.t()
  def week_period(period) do
    if is_map(period) do
      case {period[:from], period[:to]} do
        {nil, nil} -> "N/A"
        {week, week} -> week(week)
        {nil, week} -> week(week)
        {week, nil} -> week(week)
        {from, to} -> "#{week(from)} ~ #{week(to)}"
      end
    else
      "N/A"
    end
  end

  @spec year_period(map | nil) :: String.t()
  def year_period(period) do
    if is_map(period) do
      case {period[:from], period[:to]} do
        {%{year: year}, %{year: year}} -> to_string(year)
        {nil, %{year: year}} -> to_string(year)
        {%{year: year}, nil} -> to_string(year)
        {%{year: from}, %{year: to}} -> "#{from} ~ #{to}"
        {_from, _to} -> "N/A"
      end
    else
      "N/A"
    end
  end
end
