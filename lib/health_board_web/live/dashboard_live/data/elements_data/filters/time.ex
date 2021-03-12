defmodule HealthBoardWeb.DashboardLive.ElementsData.Filters.Time do
  alias HealthBoardWeb.Helpers.TimeData

  @spec period_date_range(map, atom, map, map, keyword) :: map
  def period_date_range(data, field, params, _filters, _opts \\ []) do
    key =
      case Map.fetch(params, "period") do
        {:ok, key} -> String.to_atom(key)
        _error -> :period
      end

    case Map.fetch(data, key) do
      {:ok, %{type: type, from: from, to: to, boundary: %{from: min, to: max}}} ->
        date_range =
          case type do
            :all -> %{from: min, to: max}
            :yearly -> %{from: from_year(from, min), to: to_year(to, max)}
            :monthly -> %{from: from_month(from, min), to: to_month(to, max)}
            :weekly -> %{from: from_week(from, min), to: to_week(to, max)}
            :daily -> %{from: from_date(from, min), to: to_date(to, max)}
          end

        Map.put(data, field, date_range)

      _result ->
        data
    end
  end

  defp from_year(nil, min), do: min
  defp from_year(year, %{year: year} = min), do: min
  defp from_year(%{year: year}, _min), do: Date.from_erl!({year, 1, 1})

  defp from_month(nil, min), do: min
  defp from_month(%{year: year, month: month}, %{year: year, month: month} = min), do: min
  defp from_month(%{year: year, month: month}, _min), do: Date.from_erl!({year, month, 1})

  defp from_week(from, min) do
    if is_nil(from) do
      min
    else
      from_date(TimeData.create_date_with_year_and_week(from.year, from.week, boundary: :from), min)
    end
  end

  defp from_date(nil, min), do: min
  defp from_date(from, min), do: if(Date.compare(from, min) == :lt, do: min, else: from)

  defp to_year(nil, max), do: max
  defp to_year(year, %{year: year} = max), do: max
  defp to_year(%{year: year}, _max), do: Date.from_erl!({year, 12, 31})

  defp to_month(to, max) do
    if is_nil(to) do
      max
    else
      %{year: year, month: month} = to

      if year == max.year and month == max.month do
        max
      else
        to_date(TimeData.create_date_with_year_and_month(year, month, boundary: :to), max)
      end
    end
  end

  defp to_week(to, max) do
    if is_nil(to) do
      max
    else
      to_date(TimeData.create_date_with_year_and_week(to.year, to.week, boundary: :to), max)
    end
  end

  defp to_date(nil, max), do: max
  defp to_date(to, max), do: if(Date.compare(to, max) == :gt, do: max, else: to)

  @spec date_week(map, atom, map, map, keyword) :: map
  def date_week(data, field, params, _filters, _opts \\ []) do
    key =
      case Map.fetch(params, "date") do
        {:ok, key} -> String.to_atom(key)
        _error -> :date
      end

    case Map.fetch(data, key) do
      {:ok, %Date{} = date} -> Map.put(data, field, TimeData.create_yearweek_with_date(date).week)
      _result -> data
    end
  end
end
