defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData.Time do
  alias HealthBoardWeb.Helpers.Humanize

  @spec date(map) :: map
  def date(params) do
    date = date_value(params["date"], params["default"])

    %{name: "date", value: date, verbose_value: Humanize.date(date), options: date_options(date, params)}
  end

  defp date_value(date, default) do
    if is_nil(date) do
      today = Date.utc_today()

      if is_nil(default) do
        today
      else
        if String.contains?(default, "=") do
          case URI.decode_query(default) do
            %{"alias" => date_alias} -> parse_date_alias(today, date_alias)
            _map -> nil
          end
        else
          parse_date(default) || today
        end
      end
    else
      parse_date(date) || date_value(nil, default)
    end
  end

  defp date_options(current_date, params) do
    %{}
    |> maybe_put(:from_date, handle_from_date(current_date, params))
    |> maybe_put(:to_date, handle_to_date(current_date, params))
  end

  @spec date_period(map) :: map
  def date_period(_params) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    %{name: "date_period", value: %{from: yesterday, to: today}, verbose_value: "19/04/2020 ~ 20/04/2020"}
  end

  @spec period(map) :: map
  def period(_params) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    %{name: "period", value: %{type: :daily, from: yesterday, to: today}, verbose_value: "19/04/2020 ~ 20/04/2020"}
  end

  defp handle_from_date(current_date, params) do
    case params do
      %{"from_date" => from_date} -> parse_date(from_date)
      %{"from_date_alias" => date_alias} -> parse_date_alias(current_date, date_alias)
      _ -> nil
    end
  end

  defp handle_to_date(current_date, params) do
    case params do
      %{"to_date" => from_date} -> parse_date(from_date)
      %{"to_date_alias" => date_alias} -> parse_date_alias(current_date, date_alias)
      _ -> nil
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp parse_date(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> date
      _error -> nil
    end
  end

  defp parse_date_alias(_date, "yesterday"), do: Date.add(Date.utc_today(), -1)
  defp parse_date_alias(_date, "tomorrow"), do: Date.add(Date.utc_today(), 1)
  defp parse_date_alias(_date, "today"), do: Date.utc_today()
  defp parse_date_alias(date, "fortnight_before"), do: Date.add(date, -14)
  defp parse_date_alias(date, _date_alias), do: date
end
