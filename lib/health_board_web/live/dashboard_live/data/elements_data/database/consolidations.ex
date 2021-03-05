defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations do
  alias HealthBoard.Contexts.Consolidations.{
    ConsolidationsGroups,
    DayLocationConsolidation,
    LocationConsolidation,
    MonthLocationConsolidation,
    WeekLocationConsolidation,
    YearLocationsConsolidations
  }

  alias HealthBoardWeb.DashboardLive.ElementsData

  @type consolidation ::
          DayLocationConsolidation
          | LocationConsolidation
          | MonthLocationConsolidation
          | WeekLocationConsolidation
          | YearLocationsConsolidations

  @spec fetch_date(map, map, String.t(), keyword) :: {:ok, Date.t()} | :error
  def fetch_date(data, params, key \\ "date", _opts \\ []) do
    case Map.fetch(params, key) do
      {:ok, date} -> do_fetch_date(data, date)
      :error -> Map.fetch(data, String.to_atom(key))
    end
  rescue
    _error -> :error
  end

  defp do_fetch_date(data, date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> {:ok, date}
      _error -> Map.fetch(data, String.to_atom(date))
    end
  end

  @spec fetch_date_range(map, map, keyword) :: {:ok, Date.t() | list(Date.t())} | :error
  def fetch_date_range(data, params, opts \\ []) do
    case {fetch_date(data, params, "from_date", opts), fetch_date(data, params, "to_date", opts)} do
      {:error, :error} -> fetch_date(data, params, "date", opts)
      {{:ok, from}, :error} -> {:ok, from}
      {:error, {:ok, to}} -> {:ok, to}
      {{:ok, from}, {:ok, to}} -> {:ok, [from, to]}
    end
  end

  @spec fetch_dates(map, map, keyword) :: {:ok, list({atom, list(Date.t()) | Date.t()})} | :error
  def fetch_dates(data, params, opts \\ []) do
    case Map.fetch(params, "dates") do
      {:ok, dates} -> do_fetch_dates(data, dates)
      :error -> with :error <- Map.fetch(data, :dates), do: fetch_date_range(data, params, opts)
    end
    |> case do
      {:ok, [from, to]} -> {:ok, [{:from_date, from}, {:to_date, to}]}
      {:ok, [date]} -> {:ok, [{:date, date}]}
      {:ok, dates} when is_list(dates) -> {:ok, [{:dates, dates}]}
      {:ok, %Date{} = date} -> {:ok, [{:date, date}]}
      _result -> :error
    end
  end

  defp do_fetch_dates(data, dates) do
    {:ok, String.split(dates, ",") |> Enum.map(&Date.from_iso8601!/1)}
  rescue
    _error -> Map.fetch(data, String.to_atom(dates))
  end

  @spec fetch_group(map, map, keyword) :: {:ok, integer} | :error
  def fetch_group(_data, params, opts \\ []) do
    with {:ok, group} <- Map.fetch(params, "group") do
      case ElementsData.apply_and_cache(ConsolidationsGroups, :fetch_id!, [group], opts) do
        id when is_integer(id) -> {:ok, id}
        _result -> :error
      end
    end
  end

  @spec fetch_location_id(map, map, keyword) :: {:ok, integer} | :error
  def fetch_location_id(data, params, _opts \\ []) do
    case Map.fetch(params, "location_id") do
      {:ok, location_id} -> do_fetch_location_id(data, location_id)
      :error -> Map.fetch(data, :location_id)
    end
  rescue
    _error -> :error
  end

  defp do_fetch_location_id(data, location_id) do
    {:ok, String.to_integer(location_id)}
  rescue
    _error -> Map.fetch(data, String.to_atom(location_id))
  end

  @spec fetch_locations_ids(map, map, keyword) :: {:ok, list({atom, integer})} | :error
  def fetch_locations_ids(data, params, opts \\ []) do
    case Map.fetch(params, "locations_ids") do
      {:ok, locations_ids} -> Map.fetch(data, String.to_atom(locations_ids))
      :error -> with :error <- Map.fetch(data, :locations_ids), do: fetch_location_id(data, params, opts)
    end
    |> case do
      {:ok, locations_ids} when is_list(locations_ids) -> {:ok, [{:locations_ids, locations_ids}]}
      {:ok, location_id} when is_integer(location_id) -> {:ok, [{:location_id, location_id}]}
      _result -> :error
    end
  end

  @spec fetch_month(map, map, String.t(), keyword) :: {:ok, integer} | :error
  def fetch_month(data, params, key \\ "month", _opts \\ []) do
    case Map.fetch(params, key) do
      {:ok, month} -> do_fetch_month(data, month)
      :error -> Map.fetch(data, String.to_atom(key))
    end
  rescue
    _error -> :error
  end

  defp do_fetch_month(data, month) do
    {:ok, String.to_integer(month)}
  rescue
    _error -> Map.fetch(data, String.to_atom(month))
  end

  @spec fetch_month_range(map, map, keyword) :: {:ok, integer | list(integer)} | :error
  def fetch_month_range(data, params, opts \\ []) do
    case {fetch_month(data, params, "from_month", opts), fetch_month(data, params, "to_month", opts)} do
      {:error, :error} -> fetch_month(data, params, "month", opts)
      {{:ok, from}, :error} -> {:ok, from}
      {:error, {:ok, to}} -> {:ok, to}
      {{:ok, from}, {:ok, to}} -> {:ok, [from, to]}
    end
  end

  @spec fetch_months(map, map, keyword) :: {:ok, list({atom, list(integer) | integer})} | :error
  def fetch_months(data, params, opts) do
    case Map.fetch(params, "months") do
      {:ok, months} -> do_fetch_months(data, months)
      :error -> with :error <- Map.fetch(data, :months), do: fetch_month_range(data, params, opts)
    end
    |> case do
      {:ok, [from, to]} -> {:ok, [{:from_month, from}, {:to_month, to}]}
      {:ok, [month]} -> {:ok, [{:month, month}]}
      {:ok, months} when is_list(months) -> {:ok, [{:months, months}]}
      {:ok, month} when is_integer(month) -> {:ok, [{:month, month}]}
      _result -> :error
    end
  end

  defp do_fetch_months(data, months) do
    {:ok, String.split(months, ",") |> Enum.map(&String.to_integer/1)}
  rescue
    _error -> Map.fetch(data, String.to_atom(months))
  end

  @spec fetch_period(map, map, String.t(), keyword) :: {:ok, map} | :error
  def fetch_period(data, _params, key \\ "period", _opts \\ []) do
    Map.fetch(data, String.to_atom(key))
  end

  @spec fetch_year(map, map, String.t(), keyword) :: {:ok, integer} | :error
  def fetch_year(data, params, key \\ "year", _opts \\ []) do
    case Map.fetch(params, key) do
      {:ok, year} -> do_fetch_year(data, year)
      :error -> Map.fetch(data, String.to_atom(key))
    end
  rescue
    _error -> :error
  end

  defp do_fetch_year(data, year) do
    {:ok, String.to_integer(year)}
  rescue
    _error -> Map.fetch(data, String.to_atom(year))
  end

  @spec fetch_year_range(map, map, keyword) :: {:ok, integer | list(integer)} | :error
  def fetch_year_range(data, params, opts \\ []) do
    case {fetch_year(data, params, "from_year", opts), fetch_year(data, params, "to_year", opts)} do
      {:error, :error} -> fetch_year(data, params, "year", opts)
      {{:ok, from}, :error} -> {:ok, from}
      {:error, {:ok, to}} -> {:ok, to}
      {{:ok, from}, {:ok, to}} -> {:ok, [from, to]}
    end
  end

  @spec fetch_years(map, map, keyword) :: {:ok, list({atom, list(integer) | integer})} | :error
  def fetch_years(data, params, opts \\ []) do
    case Map.fetch(params, "years") do
      {:ok, years} -> do_fetch_years(data, years)
      :error -> with :error <- Map.fetch(data, :years), do: fetch_year_range(data, params, opts)
    end
    |> case do
      {:ok, [from, to]} -> {:ok, [{:from_year, from}, {:to_year, to}]}
      {:ok, [year]} -> {:ok, [{:year, year}]}
      {:ok, years} when is_list(years) -> {:ok, [{:years, years}]}
      {:ok, year} when is_integer(year) -> {:ok, [{:year, year}]}
      _result -> :error
    end
  end

  defp do_fetch_years(data, years) do
    {:ok, String.split(years, ",") |> Enum.map(&String.to_integer/1)}
  rescue
    _error -> Map.fetch(data, String.to_atom(years))
  end

  @spec fetch_week(map, map, String.t(), keyword) :: {:ok, integer} | :error
  def fetch_week(data, params, key \\ "week", _opts \\ []) do
    case Map.fetch(params, key) do
      {:ok, week} -> do_fetch_week(data, week)
      :error -> Map.fetch(data, String.to_atom(key))
    end
  rescue
    _error -> :error
  end

  defp do_fetch_week(data, week) do
    {:ok, String.to_integer(week)}
  rescue
    _error -> Map.fetch(data, String.to_atom(week))
  end

  @spec fetch_week_range(map, map, keyword) :: {:ok, integer | list(integer)} | :error
  def fetch_week_range(data, params, opts \\ []) do
    case {fetch_week(data, params, "from_week", opts), fetch_week(data, params, "to_week", opts)} do
      {:error, :error} -> fetch_week(data, params, "week", opts)
      {{:ok, from}, :error} -> {:ok, from}
      {:error, {:ok, to}} -> {:ok, to}
      {{:ok, from}, {:ok, to}} -> {:ok, [from, to]}
    end
  end

  @spec fetch_weeks(map, map, keyword) :: {:ok, list({atom, list(integer) | integer})} | :error
  def fetch_weeks(data, params, opts \\ []) do
    case Map.fetch(params, "weeks") do
      {:ok, weeks} -> do_fetch_weeks(data, weeks)
      :error -> with :error <- Map.fetch(data, :weeks), do: fetch_week_range(data, params, opts)
    end
    |> case do
      {:ok, [from, to]} -> {:ok, [{:from_week, from}, {:to_week, to}]}
      {:ok, [week]} -> {:ok, [{:week, week}]}
      {:ok, weeks} when is_list(weeks) -> {:ok, [{:weeks, weeks}]}
      {:ok, week} when is_integer(week) -> {:ok, [{:week, week}]}
      _result -> :error
    end
  end

  defp do_fetch_weeks(data, weeks) do
    {:ok, String.split(weeks, ",") |> Enum.map(&String.to_integer/1)}
  rescue
    _error -> Map.fetch(data, String.to_atom(weeks))
  end

  @spec maybe_append(list, any) :: list
  def maybe_append(list, {:ok, item}) when is_list(item), do: item ++ list
  def maybe_append(list, _result), do: list

  @spec maybe_preload(map, keyword) :: keyword
  def maybe_preload(params, manager_params) do
    case Map.fetch(params, "preload") do
      {:ok, "location"} -> [{:preload, :location} | manager_params]
      _result -> manager_params
    end
  end

  @spec maybe_sum_by(list(consolidation), map) :: list(consolidation)
  def maybe_sum_by(data, params) do
    case Map.fetch(params, "sum_by") do
      {:ok, "location"} -> sum_by_location(data)
      {:ok, "time"} -> sum_by_time(data)
      _result -> data
    end
  end

  defp sum_by_location(data) do
    data
    |> Enum.group_by(& &1.location_id)
    |> Enum.map(&sum_total(elem(&1, 1)))
  end

  defp sum_by_time(data) do
    case Enum.at(data, 0, %{})[:__struct__] do
      DayLocationConsolidation ->
        data
        |> Enum.group_by(& &1.date)
        |> Enum.map(&sum_total(elem(&1, 1)))

      WeekLocationConsolidation ->
        data
        |> Enum.group_by(&{&1.year, &1.week})
        |> Enum.map(&sum_total(elem(&1, 1)))

      MonthLocationConsolidation ->
        data
        |> Enum.group_by(&{&1.year, &1.month})
        |> Enum.map(&sum_total(elem(&1, 1)))

      YearLocationConsolidation ->
        data
        |> Enum.group_by(& &1.year)
        |> Enum.map(&sum_total(elem(&1, 1)))

      _result ->
        data
    end
  end

  @spec sum_total(list(consolidation)) :: consolidation
  def sum_total(consolidations) do
    Enum.reduce(consolidations, fn c1, c2 -> Map.put(c2, :total, c1.total + c2.total) end)
  end
end
