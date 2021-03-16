defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Period do
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.{All, Daily, Monthly, Weekly, Yearly}

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, filters, opts \\ []) do
    case Consolidations.fetch_period(data, params, "period", opts) do
      {:ok, %{type: :all}} ->
        All.get(data, field, params, filters, opts)

      {:ok, %{type: type, from: from, to: to}} ->
        case type do
          :yearly -> do_get(get_yearly(from, to, data, field, params, filters, opts), field, params)
          :monthly -> do_get(get_monthly(from, to, data, field, params, filters, opts), field, params)
          :weekly -> do_get(get_weekly(from, to, data, field, params, filters, opts), field, params)
          :daily -> do_get(get_daily(from, to, data, field, params, filters, opts), field, params)
          _type -> data
        end

      :error ->
        data
    end
  end

  defp get_yearly(%{year: y1}, %{year: y2}, data, field, params, filters, opts) do
    Yearly.list(data, field, add_time_param(params, y1, y2, "year", "years"), filters, opts)
  end

  defp get_monthly(%{year: y1, month: m1}, %{year: y2, month: m2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(m1, m2, "month", "months")

    Monthly.list(data, field, params, filters, opts)
  end

  defp get_weekly(%{year: y1, week: w1}, %{year: y2, week: w2}, data, field, params, filters, opts) do
    params =
      params
      |> add_time_param(y1, y2, "year", "years")
      |> add_time_param(w1, w2, "week", "weeks")

    Weekly.list(data, field, params, filters, opts)
  end

  defp get_daily(from, to, data, field, params, filters, opts) do
    Daily.list(data, field, add_time_param(params, from, to, "date", "dates"), filters, opts)
  end

  defp do_get(data, field, params) do
    case Map.fetch(data, field) do
      {:ok, list} when is_list(list) ->
        Map.put(data, field, Consolidations.maybe_sum_by(list, Map.put(params, "sum_by", nil)))

      _result ->
        data
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
