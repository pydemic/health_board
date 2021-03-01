defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.Filters.Period do
  use Surface.LiveComponent
  alias HealthBoardWeb.Helpers.TimeData
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Select
  alias Phoenix.LiveView
  alias Surface.Components.Form

  prop changes, :map, required: true
  prop filter, :map, required: true

  data type, :atom, default: nil

  data from, :any, default: nil

  data from_days, :any, default: nil
  data from_weeks, :any, default: nil
  data from_months, :any, default: nil
  data from_years, :any, default: nil

  data to, :any, default: nil

  data to_days, :any, default: nil
  data to_weeks, :any, default: nil
  data to_months, :any, default: nil
  data to_years, :any, default: nil

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <Form :if={{ @filter.disabled != true }} for={{ :period }} change="change">
        <div class="grid place-items-stretch">
          <Select name="type" label="Tipo de período" selected={{ @type }} options={{ [nil, :all, :yearly, :monthly, :weekly, :daily] }} formatter={{ &format_type/1 }} />
        </div>

        <div :if={{ @type == :yearly }} class="mt-2 grid md:grid-cols-2 gap-2 place-items-stretch">
          <Select name="from_year" label="Ano inicial" selected={{ fetch_year(@from) }} options={{ @from_years }} />
          <Select name="to_year" label="Ano final" selected={{ fetch_year(@to) }} options={{ @to_years }} />
        </div>

        <div :if={{ @type == :monthly }} class="mt-2 grid md:grid-cols-2 gap-2 place-items-stretch">
          <Select name="from_month" label="Mês inicial" selected={{ fetch_month(@from) }} options={{ @from_months }} formatter={{ &TimeData.to_month_string/1 }} />
          <Select name="from_year" label="Ano inicial" selected={{ fetch_year(@from) }} options={{ @from_years }} />

          <Select name="to_month" label="Mês final" selected={{ fetch_month(@to) }} options={{ @to_months }} formatter={{ &TimeData.to_month_string/1 }} />
          <Select name="to_year" label="Ano final" selected={{ fetch_year(@to) }} options={{ @to_years }} />
        </div>

        <div :if={{ @type == :weekly }} class="mt-2 grid md:grid-cols-2 gap-2 place-items-stretch">
          <Select name="from_week" label="Semana inicial" selected={{ fetch_week(@from) }} options={{ @from_weeks }} formatter={{ &TimeData.to_week_string/1 }} />
          <Select name="from_year" label="Ano inicial" selected={{ fetch_year(@from) }} options={{ @from_years }} />

          <Select name="to_week" label="Semana final" selected={{ fetch_week(@to) }} options={{ @to_weeks }} formatter={{ &TimeData.to_week_string/1 }} />
          <Select name="to_year" label="Ano final" selected={{ fetch_year(@to) }} options={{ @to_years }} />
        </div>

        <div :if={{ @type == :daily }} class="mt-2 grid md:grid-cols-3 gap-2 place-items-stretch">
          <Select name="from_day" label="Dia inicial" selected={{ fetch_day(@from) }} options={{ @from_days }} formatter={{ &TimeData.to_day_string/1 }} />
          <Select name="from_month" label="Mês inicial" selected={{ fetch_month(@from) }} options={{ @from_months }} formatter={{ &TimeData.to_month_string/1 }} />
          <Select name="from_year" label="Ano inicial" selected={{ fetch_year(@from) }} options={{ @from_years }} />

          <Select name="to_day" label="Dia final" selected={{ fetch_day(@to) }} options={{ @to_days }} formatter={{ &TimeData.to_day_string/1 }} />
          <Select name="to_month" label="Mês final" selected={{ fetch_month(@to) }} options={{ @to_months }} formatter={{ &TimeData.to_month_string/1 }} />
          <Select name="to_year" label="Ano final" selected={{ fetch_year(@to) }} options={{ @to_years }} />
        </div>
      </Form>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("change", %{"type" => type} = data, socket) do
    socket =
      case type do
        "all" -> all_change(socket)
        "yearly" -> yearly_change(socket, data)
        "monthly" -> monthly_change(socket, data)
        "weekly" -> weekly_change(socket, data)
        "daily" -> daily_change(socket, data)
        _type -> empty_change(socket)
      end

    {:noreply, socket}
  end

  defp all_change(%{assigns: %{changes: changes, filter: %{value: value}}} = socket) do
    changes
    |> Map.drop(["period_from", "period_to"])
    |> put_or_delete("period_type", value[:type] != :all, fn -> :all end)
    |> FiltersModal.update_changes()

    LiveView.assign(
      socket,
      type: :all,
      from: nil,
      to: nil,
      from_days: nil,
      from_weeks: nil,
      from_months: nil,
      from_years: nil,
      to_days: nil,
      to_weeks: nil,
      to_months: nil,
      to_years: nil
    )
  end

  defp yearly_change(socket, data) do
    {from, to} = parse_years(data, socket.assigns.filter)
    assign_yearly_changes(socket, from, to)
  end

  defp parse_years(data, %{value: value, options: %{from_date: from_date, to_date: to_date}}) do
    TimeData.limit_year_period(
      parse_year(data, "from") || value[:from] || to_date,
      parse_year(data, "to") || value[:to] || to_date,
      from_date,
      to_date
    )
  end

  defp parse_year(data, prefix) do
    %{year: String.to_integer(data[prefix <> "_year"])}
  rescue
    _error -> nil
  end

  defp assign_yearly_changes(socket, from, to) do
    %{
      assigns: %{
        changes: changes,
        filter: %{
          value: value,
          options: %{
            from_date: min_boundary,
            to_date: max_boundary
          }
        }
      }
    } = socket

    changes
    |> put_or_delete("period_type", value[:type] != :yearly, fn -> :yearly end)
    |> put_or_delete("period_from", from != value[:from], fn -> to_string(from.year) end)
    |> put_or_delete("period_to", to != value[:to], fn -> to_string(to.year) end)
    |> FiltersModal.update_changes()

    {from_years, to_years} = TimeData.year_period_ranges(from, to, min_boundary, max_boundary)

    LiveView.assign(
      socket,
      type: :yearly,
      from: from,
      to: to,
      from_days: nil,
      from_weeks: nil,
      from_months: nil,
      from_years: from_years,
      to_days: nil,
      to_weeks: nil,
      to_months: nil,
      to_years: to_years
    )
  end

  defp monthly_change(socket, data) do
    {from, to} = parse_months(data, socket.assigns.filter)
    assign_monthly_changes(socket, from, to)
  end

  defp parse_months(data, %{value: value, options: %{from_date: from_date, to_date: to_date}}) do
    min_boundary = TimeData.to_yearmonth(from_date)
    max_boundary = TimeData.to_yearmonth(to_date)

    TimeData.limit_yearmonth_period(
      parse_month(data, :from) || TimeData.to_yearmonth(value[:from], approximate?: true, boundary: :from) ||
        max_boundary,
      parse_month(data, :to) || TimeData.to_yearmonth(value[:to], approximate?: true, boundary: :to) || max_boundary,
      min_boundary,
      max_boundary
    )
  end

  defp parse_month(data, prefix) do
    year = String.to_integer(data["#{prefix}_year"])
    month = String.to_integer(data["#{prefix}_month"])
    TimeData.create_yearmonth(year, month, approximate?: true, boundary: prefix)
  rescue
    _error -> nil
  end

  defp assign_monthly_changes(socket, from, to) do
    %{
      assigns: %{
        changes: changes,
        filter: %{
          value: value,
          options: %{
            from_date: min_boundary,
            to_date: max_boundary
          }
        }
      }
    } = socket

    changes
    |> put_or_delete("period_type", value[:type] != :monthly, fn -> :monthly end)
    |> put_or_delete("period_from", from != value[:from], fn -> TimeData.to_yearmonth_string(from) end)
    |> put_or_delete("period_to", to != value[:to], fn -> TimeData.to_yearmonth_string(to) end)
    |> FiltersModal.update_changes()

    {from_months, to_months} = TimeData.month_period_ranges(from, to, min_boundary, max_boundary)
    {from_years, to_years} = TimeData.year_period_ranges(from, to, min_boundary, max_boundary)

    LiveView.assign(
      socket,
      type: :monthly,
      from: from,
      to: to,
      from_days: nil,
      from_weeks: nil,
      from_months: from_months,
      from_years: from_years,
      to_days: nil,
      to_weeks: nil,
      to_months: to_months,
      to_years: to_years
    )
  end

  defp weekly_change(socket, data) do
    {from, to} = parse_weeks(data, socket.assigns.filter)
    assign_weekly_changes(socket, from, to)
  end

  defp parse_weeks(data, %{value: value, options: %{from_date: from_date, to_date: to_date}}) do
    min_boundary = TimeData.to_yearweek(from_date)
    max_boundary = TimeData.to_yearweek(to_date)

    TimeData.limit_yearweek_period(
      parse_week(data, :from) || TimeData.to_yearweek(value[:from], approximate?: true, boundary: :from) ||
        max_boundary,
      parse_week(data, :to) || TimeData.to_yearweek(value[:to], approximate?: true, boundary: :to) || max_boundary,
      min_boundary,
      max_boundary
    )
  end

  defp parse_week(data, prefix) do
    year = String.to_integer(data["#{prefix}_year"])
    week = String.to_integer(data["#{prefix}_week"])
    TimeData.create_yearweek(year, week, approximate?: true, boundary: prefix)
  rescue
    _error -> nil
  end

  defp assign_weekly_changes(socket, from, to) do
    %{
      assigns: %{
        changes: changes,
        filter: %{
          value: value,
          options: %{
            from_date: min_boundary,
            to_date: max_boundary
          }
        }
      }
    } = socket

    changes
    |> put_or_delete("period_type", value[:type] != :weekly, fn -> :weekly end)
    |> put_or_delete("period_from", from != value[:from], fn -> TimeData.to_yearweek_string(from) end)
    |> put_or_delete("period_to", to != value[:to], fn -> TimeData.to_yearweek_string(to) end)
    |> FiltersModal.update_changes()

    min_boundary = fetch_yearweek(min_boundary)
    max_boundary = fetch_yearweek(max_boundary)

    {from_weeks, to_weeks} = TimeData.week_period_ranges(from, to, min_boundary, max_boundary)
    {from_years, to_years} = TimeData.year_period_ranges(from, to, min_boundary, max_boundary)

    LiveView.assign(
      socket,
      type: :weekly,
      from: from,
      to: to,
      from_days: nil,
      from_weeks: from_weeks,
      from_months: nil,
      from_years: from_years,
      to_days: nil,
      to_weeks: to_weeks,
      to_months: nil,
      to_years: to_years
    )
  end

  defp daily_change(socket, data) do
    {from, to} = parse_dates(data, socket.assigns.filter)
    assign_daily_changes(socket, from, to)
  end

  defp parse_dates(data, %{value: value, options: %{from_date: min_boundary, to_date: max_boundary}}) do
    TimeData.limit_date_period(
      parse_date(data, :from) || TimeData.to_date(value[:from], approximate?: true, boundary: :from) || max_boundary,
      parse_date(data, :to) || TimeData.to_date(value[:to], approximate?: true, boundary: :to) || max_boundary,
      min_boundary,
      max_boundary
    )
  end

  defp parse_date(data, prefix) do
    year = String.to_integer(data["#{prefix}_year"])
    month = String.to_integer(data["#{prefix}_month"])
    day = String.to_integer(data["#{prefix}_day"])
    TimeData.create_date(year, month, day, approximate?: true, boundary: prefix)
  rescue
    _error -> nil
  end

  defp assign_daily_changes(socket, from, to) do
    %{
      assigns: %{
        changes: changes,
        filter: %{
          value: value,
          options: %{
            from_date: min_boundary,
            to_date: max_boundary
          }
        }
      }
    } = socket

    changes
    |> put_or_delete("period_type", value[:type] != :daily, fn -> :daily end)
    |> put_or_delete("period_from", from != value[:from], fn -> Date.to_iso8601(from) end)
    |> put_or_delete("period_to", to != value[:to], fn -> Date.to_iso8601(to) end)
    |> FiltersModal.update_changes()

    {from_days, to_days} = TimeData.day_period_ranges(from, to, min_boundary, max_boundary)
    {from_months, to_months} = TimeData.month_period_ranges(from, to, min_boundary, max_boundary)
    {from_years, to_years} = TimeData.year_period_ranges(from, to, min_boundary, max_boundary)

    LiveView.assign(
      socket,
      type: :daily,
      from: from,
      to: to,
      from_days: from_days,
      from_weeks: nil,
      from_months: from_months,
      from_years: from_years,
      to_days: to_days,
      to_weeks: nil,
      to_months: to_months,
      to_years: to_years
    )
  end

  defp empty_change(socket) do
    socket.assigns.changes
    |> Map.drop(["period_type", "period_from", "period_to"])
    |> FiltersModal.update_changes()

    LiveView.assign(
      socket,
      type: nil,
      from: nil,
      to: nil,
      from_days: nil,
      from_weeks: nil,
      from_months: nil,
      from_years: nil,
      to_days: nil,
      to_weeks: nil,
      to_months: nil,
      to_years: nil
    )
  end

  defp fetch_date(map), do: TimeData.to_date(map, approximate?: true)

  defp fetch_day(%{day: day}), do: day
  defp fetch_day(map), do: fetch_date(map).day

  defp fetch_month(%{month: month}), do: month
  defp fetch_month(map), do: fetch_date(map).month

  defp fetch_week(%{week: week}), do: week
  defp fetch_week(map), do: fetch_yearweek(map).week

  defp fetch_yearweek(map), do: TimeData.to_yearweek(map, approximate?: true)

  defp fetch_year(%{year: year}), do: year
  defp fetch_year(map), do: fetch_date(map).year

  defp format_type(:all), do: "Todo o período"
  defp format_type(:yearly), do: "Anual"
  defp format_type(:monthly), do: "Mensal"
  defp format_type(:weekly), do: "Semanal"
  defp format_type(:daily), do: "Diário"
  defp format_type(nil), do: "Escolha uma opção"

  defp put_or_delete(map, key, true, value_function), do: Map.put(map, key, value_function.())
  defp put_or_delete(map, key, _condition, _value_function), do: Map.delete(map, key)
end
