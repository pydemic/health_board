defmodule HealthBoardWeb.Helpers.TimeData do
  @type date_alias :: :fortnight_before | :today | :tomorrow | :yesterday
  @type type :: :all | :daily | :monthly | :weekly | :yearly
  @type yearmonth :: Date.t() | %{year: integer, month: pos_integer}
  @type yearweek :: %{year: integer, week: pos_integer}

  @date_aliases %{
    "fortnight_before" => :fortnight_before,
    "today" => :today,
    "tomorrow" => :tomorrow,
    "yesterday" => :yesterday
  }

  @types %{
    "all" => :all,
    "yearly" => :yearly,
    "monthly" => :monthly,
    "weekly" => :weekly,
    "daily" => :daily
  }

  @spec asc_date_boundary(Date.t(), Date.t()) :: {Date.t(), Date.t()}
  def asc_date_boundary(d1, d2) do
    if Date.compare(d1, d2) == :gt do
      {d2, d1}
    else
      {d1, d2}
    end
  end

  @spec asc_yearmonth_boundary(yearmonth, yearmonth) :: {yearmonth, yearmonth}
  def asc_yearmonth_boundary(%{year: y1, month: m1} = ym1, %{year: y2, month: m2} = ym2) do
    if y1 > y2 do
      {ym2, ym1}
    else
      if y1 == y2 and m1 > m2 do
        {ym2, ym1}
      else
        {ym1, ym2}
      end
    end
  end

  @spec asc_yearweek_boundary(yearweek, yearweek) :: {yearweek, yearweek}
  def asc_yearweek_boundary(%{year: y1, week: w1} = yw1, %{year: y2, week: w2} = yw2) do
    if y1 > y2 do
      {yw2, yw1}
    else
      if y1 == y2 and w1 > w2 do
        {yw2, yw1}
      else
        {yw1, yw2}
      end
    end
  end

  @spec create_date(integer, pos_integer, pos_integer, keyword) :: Date.t() | nil
  def create_date(year, month, day, opts \\ []) do
    case Date.new(year, month, day) do
      {:ok, date} -> date
      _error -> maybe_approximate(&create_date_with_year_and_month(year, &1), &handle_default_date/1, opts)
    end
  end

  @spec create_date_with_year(integer, keyword) :: Date.t() | nil
  def create_date_with_year(year, opts \\ []) do
    if Keyword.get(opts, :boundary, :from) == :to do
      create_date(year, 12, 31, Keyword.delete(opts, :approximate?))
    else
      create_date(year, 1, 1, Keyword.delete(opts, :approximate?))
    end
  end

  @spec create_date_with_year_and_month(integer, pos_integer, keyword) :: Date.t() | nil
  def create_date_with_year_and_month(year, month, opts \\ []) do
    if Keyword.get(opts, :boundary, :from) == :to do
      with %Date{year: year, month: month} = date <- create_date(year, month, 1) do
        create_date(year, month, Date.days_in_month(date), Keyword.delete(opts, :approximate?))
      end
    else
      create_date(year, month, 1, Keyword.delete(opts, :approximate?))
    end
    |> case do
      %Date{} = date -> date
      nil -> maybe_approximate(&create_date_with_year(year, &1), &handle_default_date/1, opts)
    end
  end

  @spec create_date_with_year_and_week(integer, integer | :last, keyword) :: Date.t() | nil
  def create_date_with_year_and_week(year, week, opts \\ []) do
    case find_week_range(year, week) do
      %Date.Range{} = range ->
        if Keyword.get(opts, :boundary, :from) == :to do
          range.last
        else
          range.first
        end

      _result ->
        maybe_approximate(&create_date_with_year(year, &1), &handle_default_date/1, opts)
    end
  end

  @spec create_yearmonth(integer, pos_integer, keyword) :: yearmonth | nil
  def create_yearmonth(year, month, opts \\ []) do
    case create_date_with_year_and_month(year, month, opts) do
      %{year: year, month: month} -> %{year: year, month: month}
      _result -> handle_default_yearmonth(opts)
    end
  end

  @spec create_yearmonth_with_year(integer, keyword) :: yearmonth | nil
  def create_yearmonth_with_year(year, opts \\ []) do
    case create_date_with_year(year, opts) do
      %{year: year, month: month} -> %{year: year, month: month}
      _result -> handle_default_yearmonth(opts)
    end
  end

  @spec create_yearweek(integer, integer, keyword) :: yearweek | nil
  def create_yearweek(year, week, opts \\ []) do
    case find_week_range(year, week) do
      %Date.Range{} -> %{year: year, week: week}
      _result -> handle_default_yearweek(opts)
    end
  end

  @spec create_yearweek_with_date(Date.t(), keyword) :: yearweek | nil
  def create_yearweek_with_date(date, opts \\ []) do
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))
    %{year: year, week: week}
  rescue
    _error -> handle_default_yearweek(opts)
  end

  @spec create_yearweek_with_year(integer, keyword) :: yearweek | nil
  def create_yearweek_with_year(year, opts \\ []) do
    case create_date_with_year(year, opts) do
      %Date{} = date -> create_yearweek_with_date(date, opts)
      _result -> handle_default_yearweek(opts)
    end
  end

  @spec create_yearweek_with_year_and_month(integer, pos_integer, keyword) :: yearweek | nil
  def create_yearweek_with_year_and_month(year, month, opts \\ []) do
    case create_date_with_year_and_month(year, month, opts) do
      %Date{} = date -> create_yearweek_with_date(date, opts)
      _result -> handle_default_yearweek(opts)
    end
  end

  @spec create_yearweek_with_year_month_and_day(integer, pos_integer, pos_integer, keyword) :: yearweek | nil
  def create_yearweek_with_year_month_and_day(year, month, day, opts \\ []) do
    case create_date(year, month, day, opts) do
      %Date{} = date -> create_yearweek_with_date(date, opts)
      _result -> handle_default_yearweek(opts)
    end
  end

  @spec date_alias(Date.t() | nil, date_alias) :: Date.t()
  def date_alias(date \\ nil, atom)
  def date_alias(_date, :today), do: Date.utc_today()
  def date_alias(_date, :yesterday), do: Date.add(Date.utc_today(), -1)
  def date_alias(_date, :tomorrow), do: Date.add(Date.utc_today(), 1)
  def date_alias(%Date{} = date, :fortnight_before), do: Date.add(date, -14)
  def date_alias(_date, atom), do: date_alias(Date.utc_today(), atom)

  @spec date_alias_string_to_atom(String.t()) :: date_alias
  def date_alias_string_to_atom(string), do: Map.get(@date_aliases, string, :today)

  @spec day_period_ranges(Date.t(), Date.t(), Date.t(), Date.t()) :: {Range.t(), Range.t()}
  def day_period_ranges(from, to, min_boundary, max_boundary) do
    {from, to} = asc_date_boundary(from, to)
    {min_boundary, max_boundary} = asc_date_boundary(min_boundary, max_boundary)

    {
      Range.new(min_day(min_boundary, from), min(max_day(to, from), max_day(max_boundary, from))),
      Range.new(max(min_day(from, to), min_day(min_boundary, to)), max_day(max_boundary, to))
    }
  end

  defp min_day(%{year: y1, month: m1, day: d1}, %{year: y2, month: m2}) do
    if y1 == y2 and m1 == m2 do
      d1
    else
      1
    end
  end

  defp max_day(%{year: y1, month: m1, day: d1}, %{year: y2, month: m2} = date2) do
    if y1 == y2 and m1 == m2 do
      d1
    else
      Date.days_in_month(date2)
    end
  end

  @spec find_week_range(integer, integer) :: Date.Range.t() | nil
  def find_week_range(year, week) do
    date =
      if week > 51 do
        Date.from_erl!({year, 12, 31})
      else
        Date.from_erl!({year, max(1, div(week, 5)), 1})
      end

    date =
      case Date.day_of_week(date) do
        1 -> date
        day_of_week -> Date.add(date, -(day_of_week - 1))
      end

    do_find_week_range(year, week, date, 0)
  rescue
    _error -> nil
  end

  defp do_find_week_range(year, week, date, attempts, direction \\ nil) do
    if attempts < 10 do
      {current_year, current_week} = :calendar.iso_week_number(Date.to_erl(date))

      cond do
        current_year > year and direction != :up -> :down
        current_year < year and direction != :down -> :up
        current_week > week and direction != :up -> :down
        current_week < week and direction != :down -> :up
        true -> :create
      end
      |> case do
        :create -> Date.range(date, Date.add(date, 6))
        :up -> do_find_week_range(year, week, Date.add(date, 7), attempts + 1, :up)
        :down -> do_find_week_range(year, week, Date.add(date, -7), attempts + 1, :down)
      end
    else
      nil
    end
  end

  @spec from_date_query(String.t(), keyword) :: Date.t() | nil
  def from_date_query(string, opts \\ []) do
    if is_binary(string) do
      if String.contains?(string, "=") do
        case URI.decode_query(string) do
          %{"alias" => date_alias} -> date_alias(date_alias_string_to_atom(date_alias))
          _map -> handle_default_date(opts)
        end
      else
        from_iso8601(string, opts)
      end
    else
      handle_default_date(opts)
    end
  end

  @spec from_iso8601(String.t(), keyword) :: Date.t() | nil
  def from_iso8601(string, opts \\ []) do
    if is_binary(string) do
      case Date.from_iso8601(string) do
        {:ok, date} -> date
        _error -> handle_default_date(opts)
      end
    else
      handle_default_date(opts)
    end
  end

  @spec from_year_string(String.t(), keyword) :: integer | nil
  def from_year_string(string, opts \\ []) do
    if is_binary(string) do
      String.to_integer(string)
    else
      handle_default_year(opts)
    end
  rescue
    _error -> handle_default_year(opts)
  end

  @spec from_yearmonth_string(String.t(), keyword) :: yearmonth | nil
  def from_yearmonth_string(string, opts \\ []) do
    if is_binary(string) do
      [year, month] = Enum.map(String.split(string, "-", parts: 2), &String.to_integer/1)
      %{year: year, month: month}
    else
      handle_default_yearmonth(opts)
    end
  rescue
    _error -> handle_default_yearmonth(opts)
  end

  @spec from_yearweek_string(String.t(), keyword) :: yearweek | nil
  def from_yearweek_string(string, opts \\ []) do
    if is_binary(string) do
      [year, week] = Enum.map(String.split(string, "-", parts: 2), &String.to_integer/1)
      %{year: year, week: week}
    else
      handle_default_yearweek(opts)
    end
  rescue
    _error -> handle_default_yearweek(opts)
  end

  @spec limit_date_period(Date.t(), Date.t(), Date.t(), Date.t()) :: {Date.t(), Date.t()}
  def limit_date_period(from, to, min_boundary, max_boundary) do
    {from, to} = asc_date_boundary(from, to)
    {min_boundary, max_boundary} = asc_date_boundary(min_boundary, max_boundary)

    from = limit_date_min(min_boundary, from)
    to = limit_date_max(max_boundary, to)

    to = limit_date_min(from, to)
    from = limit_date_max(to, from)

    {from, to}
  end

  @spec limit_date_max(Date.t(), Date.t()) :: Date.t()
  def limit_date_max(d1, d2) do
    if Date.compare(d1, d2) == :lt do
      d1
    else
      d2
    end
  end

  @spec limit_date_min(Date.t(), Date.t()) :: Date.t()
  def limit_date_min(d1, d2) do
    if Date.compare(d1, d2) == :gt do
      d1
    else
      d2
    end
  end

  @spec limit_year_period(map, map, map, map) :: {map, map}
  def limit_year_period(%{year: from}, %{year: to}, %{year: min_boundary}, %{year: max_boundary}) do
    {from, to} = if from > to, do: {to, from}, else: {from, to}

    {min_boundary, max_boundary} =
      if min_boundary > max_boundary do
        {max_boundary, min_boundary}
      else
        {min_boundary, max_boundary}
      end

    from = if min_boundary > from, do: min_boundary, else: from
    to = if max_boundary < to, do: max_boundary, else: to

    to = if from > to, do: from, else: to
    from = if to < from, do: to, else: from

    {%{year: from}, %{year: to}}
  end

  @spec limit_yearmonth_period(yearmonth, yearmonth, yearmonth, yearmonth) :: {yearmonth, yearmonth}
  def limit_yearmonth_period(from, to, min_boundary, max_boundary) do
    {from, to} = asc_yearmonth_boundary(from, to)
    {min_boundary, max_boundary} = asc_yearmonth_boundary(min_boundary, max_boundary)

    from = limit_yearmonth_min(min_boundary, from)
    to = limit_yearmonth_max(max_boundary, to)

    to = limit_yearmonth_min(from, to)
    from = limit_yearmonth_max(to, from)

    {from, to}
  end

  @spec limit_yearmonth_max(yearmonth, yearmonth) :: yearmonth
  def limit_yearmonth_max(%{year: y1, month: m1} = ym1, %{year: y2, month: m2} = ym2) do
    if y1 < y2 do
      ym1
    else
      if y1 == y2 and m1 < m2 do
        ym1
      else
        ym2
      end
    end
  end

  @spec limit_yearmonth_min(yearmonth, yearmonth) :: yearmonth
  def limit_yearmonth_min(%{year: y1, month: m1} = ym1, %{year: y2, month: m2} = ym2) do
    if y1 > y2 do
      ym1
    else
      if y1 == y2 and m1 > m2 do
        ym1
      else
        ym2
      end
    end
  end

  @spec limit_yearweek_period(yearweek, yearweek, yearweek, yearweek) :: {yearweek, yearweek}
  def limit_yearweek_period(from, to, min_boundary, max_boundary) do
    {from, to} = asc_yearweek_boundary(from, to)
    {min_boundary, max_boundary} = asc_yearweek_boundary(min_boundary, max_boundary)

    from = limit_yearweek_min(min_boundary, from)
    to = limit_yearweek_max(max_boundary, to)

    to = limit_yearweek_min(from, to)
    from = limit_yearweek_max(to, from)
    {from, to}
  end

  @spec limit_yearweek_max(yearweek, yearweek) :: yearweek
  def limit_yearweek_max(%{year: y1, week: w1} = yw1, %{year: y2, week: w2} = yw2) do
    if y1 < y2 do
      yw1
    else
      if y1 == y2 and w1 < w2 do
        yw1
      else
        yw2
      end
    end
  end

  @spec limit_yearweek_min(yearweek, yearweek) :: yearweek
  def limit_yearweek_min(%{year: y1, week: w1} = yw1, %{year: y2, week: w2} = yw2) do
    if y1 > y2 do
      yw1
    else
      if y1 == y2 and w1 > w2 do
        yw1
      else
        yw2
      end
    end
  end

  @spec month_period_ranges(yearmonth, yearmonth, yearmonth, yearmonth) :: {Range.t(), Range.t()}
  def month_period_ranges(from, to, min_boundary, max_boundary) do
    {from, to} = asc_yearmonth_boundary(from, to)
    {min_boundary, max_boundary} = asc_yearmonth_boundary(min_boundary, max_boundary)

    {
      Range.new(min_month(min_boundary, from), min(max_month(to, from), max_month(max_boundary, from))),
      Range.new(max(min_month(from, to), min_month(min_boundary, to)), max_month(max_boundary, to))
    }
  end

  defp min_month(%{year: y1, month: m1}, %{year: y2}) do
    if y1 == y2 do
      m1
    else
      1
    end
  end

  defp max_month(%{year: y1, month: m1}, %{year: y2}) do
    if y1 == y2 do
      m1
    else
      12
    end
  end

  @spec to_date(map, keyword) :: Date.t() | nil
  def to_date(value, opts \\ []) do
    case value do
      %Date{} = date -> date
      %{year: year, month: month, day: day} -> create_date(year, month, day, opts)
      %{year: year, month: month} -> create_date_with_year_and_month(year, month, opts)
      %{year: year, week: week} -> create_date_with_year_and_week(year, week, opts)
      %{year: year} -> create_date_with_year(year, opts)
      _value -> handle_default_date(opts)
    end
  end

  @spec to_yearmonth(map, keyword) :: yearmonth | nil
  def to_yearmonth(value, opts \\ []) do
    case value do
      %{year: year, month: month} -> %{year: year, month: month}
      %{year: year} -> create_yearmonth_with_year(year, opts)
      _value -> handle_default_yearmonth(opts)
    end
  end

  @spec to_yearweek(map, keyword) :: yearweek | nil
  def to_yearweek(value, opts \\ []) do
    case value do
      %{year: _year, week: _week} = yearweek -> yearweek
      %{year: year, month: month, day: day} -> create_yearweek_with_year_month_and_day(year, month, day, opts)
      %{year: year, month: month} -> create_yearweek_with_year_and_month(year, month, opts)
      %{year: year} -> create_yearweek_with_year(year, opts)
      _value -> handle_default_yearweek(opts)
    end
  end

  @spec to_day_string(integer) :: String.t()
  def to_day_string(day), do: String.pad_leading(Integer.to_string(day), 2, "0")

  @spec to_month_string(integer) :: String.t()
  def to_month_string(month), do: String.pad_leading(Integer.to_string(month), 2, "0")

  @spec to_week_string(integer) :: String.t()
  def to_week_string(week), do: String.pad_leading(Integer.to_string(week), 2, "0")

  @spec to_year_string(integer) :: String.t()
  def to_year_string(year), do: String.pad_leading(Integer.to_string(year), 4, "0")

  @spec to_yearmonth_string(yearmonth) :: String.t()
  def to_yearmonth_string(%{year: year, month: month}), do: "#{to_year_string(year)}-#{to_month_string(month)}"

  @spec to_yearweek_string(yearweek) :: String.t()
  def to_yearweek_string(%{year: year, week: week}), do: "#{to_year_string(year)}-#{to_week_string(week)}"

  @spec today :: Date.t()
  def today, do: Date.utc_today()

  @spec today_year :: integer
  def today_year, do: today().year

  @spec today_yearmonth :: yearmonth
  def today_yearmonth, do: Map.take(today(), [:year, :month])

  @spec today_yearweek :: yearweek
  def today_yearweek do
    {year, week} = :calendar.iso_week_number(Date.to_erl(today()))
    %{year: year, week: week}
  end

  @spec type_string_to_atom(String.t()) :: type | nil
  def type_string_to_atom(string), do: Map.get(@types, string)

  @spec week_period_ranges(yearweek, yearweek, yearweek, yearweek) :: {Range.t(), Range.t()}
  def week_period_ranges(from, to, min_boundary, max_boundary) do
    {from, to} = asc_yearweek_boundary(from, to)
    {min_boundary, max_boundary} = asc_yearweek_boundary(min_boundary, max_boundary)

    {
      Range.new(min_week(min_boundary, from), min(max_week(to, from), max_week(max_boundary, from))),
      Range.new(max(min_week(from, to), min_week(min_boundary, to)), max_week(max_boundary, to))
    }
  end

  defp min_week(%{year: y1, week: w1}, %{year: y2}) do
    if y1 == y2 do
      w1
    else
      1
    end
  end

  defp max_week(%{year: y1, week: w1}, %{year: y2}) do
    if y1 == y2 do
      w1
    else
      weeks_in_year(y2)
    end
  end

  @spec weeks_in_year(integer) :: integer
  def weeks_in_year(year) do
    {_year, week} = :calendar.iso_week_number({year, 12, 31})

    case week do
      1 ->
        {_year, week} = :calendar.iso_week_number({year, 12, 24})
        week

      _ ->
        week
    end
  end

  @spec year_period_ranges(map, map, map, map) :: {Range.t(), Range.t()}
  def year_period_ranges(%{year: from}, %{year: to}, %{year: min_boundary}, %{year: max_boundary}) do
    {from, to} = if from > to, do: {to, from}, else: {from, to}

    {min_boundary, max_boundary} =
      if min_boundary > max_boundary do
        {max_boundary, min_boundary}
      else
        {min_boundary, max_boundary}
      end

    {
      Range.new(min_boundary, min(to, max_boundary)),
      Range.new(max(from, min_boundary), max_boundary)
    }
  end

  defp handle_default_date(opts) do
    case Keyword.get(opts, :default) do
      function when is_function(function) -> function.()
      %Date{} = date -> date
      {%Date{} = date, atom} when is_atom(atom) and not is_nil(atom) and not is_boolean(atom) -> date_alias(date, atom)
      atom when is_atom(atom) and not is_nil(atom) and not is_boolean(atom) -> date_alias(atom)
      _default -> nil
    end
  end

  defp handle_default_year(opts) do
    case Keyword.get(opts, :default) do
      function when is_function(function) -> function.()
      year when is_integer(year) -> year
      _default -> nil
    end
  end

  defp handle_default_yearmonth(opts) do
    case Keyword.get(opts, :default) do
      function when is_function(function) -> function.()
      %{year: year, month: month} -> %{year: year, month: month}
      _default -> nil
    end
  end

  defp handle_default_yearweek(opts) do
    case Keyword.get(opts, :default) do
      function when is_function(function) -> function.()
      %{year: year, week: week} -> %{year: year, week: week}
      _default -> nil
    end
  end

  defp maybe_approximate(approximation_function, default_function, opts) do
    if Keyword.get(opts, :approximate?) == true do
      approximation_function.(opts)
    else
      default_function.(opts)
    end
  end
end
