defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Period do
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.{All, Daily, Monthly, Weekly, Yearly}

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, filters, opts \\ []) do
    case Consolidations.fetch_period(data, params, "period", opts) do
      {:ok, %{type: :all}} -> All.get(data, field, params, filters, opts)
      {:ok, %{type: :yearly, from: from, to: to}} -> get_yearly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :monthly, from: from, to: to}} -> get_monthly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :weekly, from: from, to: to}} -> get_weekly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :daily, from: from, to: to}} -> get_daily(from, to, data, field, params, filters, opts)
      :error -> data
    end
  end

  defp get_yearly(%{year: y1}, %{year: y2}, data, field, params, filters, opts) do
    data
    |> Yearly.list(field, add_time_param(params, y1, y2, "year", "years"), filters, opts)
    |> do_get(field)
  end

  defp get_monthly(%{year: y1, month: m1}, %{year: y2, month: m2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(m1, m2, "month", "months")

    data
    |> Monthly.list(field, params, filters, opts)
    |> do_get(field)
  end

  defp get_weekly(%{year: y1, week: w1}, %{year: y2, week: w2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(w1, w2, "week", "weeks")

    data
    |> Weekly.list(field, params, filters, opts)
    |> do_get(field)
  end

  defp get_daily(from, to, data, field, params, filters, opts) do
    data
    |> Daily.list(field, add_time_param(params, from, to, "date", "dates"), filters, opts)
    |> do_get(field)
  end

  defp do_get(data, field) do
    case Map.fetch(data, field) do
      {:ok, [_ | _] = list} -> Map.put(data, field, Consolidations.sum_total(list))
      {:ok, _field_data} -> Map.delete(data, field)
      _error -> data
    end
  end

  @spec list(map, atom, map, map, keyword) :: map
  def list(data, field, params, filters, opts \\ []) do
    case Consolidations.fetch_period(data, params, "period", opts) do
      {:ok, %{type: :all}} -> All.list(data, field, params, filters, opts)
      {:ok, %{type: :yearly, from: from, to: to}} -> list_yearly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :monthly, from: from, to: to}} -> list_monthly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :weekly, from: from, to: to}} -> list_weekly(from, to, data, field, params, filters, opts)
      {:ok, %{type: :daily, from: from, to: to}} -> list_daily(from, to, data, field, params, filters, opts)
      :error -> data
    end
  end

  defp list_yearly(%{year: y1}, %{year: y2}, data, field, params, filters, opts) do
    Yearly.list(data, field, add_time_param(params, y1, y2, "year", "years"), filters, opts)
  end

  defp list_monthly(%{year: y1, month: m1}, %{year: y2, month: m2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(m1, m2, "month", "months")

    Monthly.list(data, field, params, filters, opts)
  end

  defp list_weekly(%{year: y1, week: w1}, %{year: y2, week: w2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(w1, w2, "week", "weeks")

    Weekly.list(data, field, params, filters, opts)
  end

  defp list_daily(from, to, data, field, params, filters, opts) do
    Daily.list(data, field, add_time_param(params, from, to, "date", "dates"), filters, opts)
  end

  defp add_time_param(params, from, to, singular_key, plural_key) do
    case {from, to} do
      {from, from} -> Map.put(params, singular_key, to_string(from))
      {from, to} -> Map.put(params, plural_key, "#{from},#{to}")
    end
  end
end
