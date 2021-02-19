defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.Filters.Date do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Select
  alias Phoenix.LiveView
  alias Surface.Components.Form

  prop changes, :map, required: true
  prop filter, :map, required: true

  data date, :any, default: nil
  data days, :any, default: nil
  data months, :any, default: nil
  data years, :any, default: nil

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <Form :if={{ @filter.disabled != true }} for={{ :date }} change="change">
        <div class="grid md:grid-cols-3 gap-2 place-items-stretch">
          <Select name="day" label="Dia" selected={{ fetch_day(@date) }} options={{ @days || fetch_days(fetch_date(@date), @filter.options) }} formatter={{ &format_day/1 }} />
          <Select name="month" label="Mês" selected={{ fetch_month(@date) }} options={{ @months || fetch_months(fetch_date(@date), @filter.options) }} formatter={{ &format_day/1 }} />
          <Select name="year" label="Ano" selected={{ fetch_year(@date) }} options={{ @years || fetch_years(@filter.options) }} />
        </div>
      </Form>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("change", %{"year" => year, "month" => month, "day" => day}, socket) do
    {:noreply, change(socket, String.to_integer(year), String.to_integer(month), String.to_integer(day))}
  end

  defp change(socket, year, month, day) do
    case Date.new(year, month, day) do
      {:ok, date} -> assign_changes(socket, date)
      _error -> change_with_day_adjustment(socket, year, month)
    end
  end

  defp assign_changes(socket, date) do
    %{assigns: %{changes: changes, filter: %{value: value, options: options}}} = socket

    if Date.compare(value, date) != :eq do
      FiltersModal.update_changes(Map.put(changes, "date", Date.to_iso8601(date)))
    else
      FiltersModal.update_changes(Map.delete(changes, "date"))
    end

    LiveView.assign(
      socket,
      date: date,
      days: fetch_days(date, options),
      months: fetch_months(date, options),
      years: fetch_years(options)
    )
  end

  defp change_with_day_adjustment(socket, year, month) do
    case Date.new(year, month, 1) do
      {:ok, date} -> assign_changes(socket, Date.from_erl!({year, month, Date.days_in_month(date)}))
      _error -> socket
    end
  end

  defp fetch_date(%Date{} = date), do: date
  defp fetch_date(_date), do: Date.utc_today()

  defp fetch_day(date), do: fetch_date(date).day
  defp fetch_month(date), do: fetch_date(date).month
  defp fetch_year(date), do: fetch_date(date).year

  defp fetch_days(%{year: year, month: month} = date, %{from_date: from, to_date: to}) do
    days = Date.days_in_month(date)

    cond do
      year == from.year and month == from.month -> Range.new(from.day, days)
      year == to.year and month == to.month -> Range.new(1, to.day)
      true -> Range.new(1, days)
    end
  end

  defp fetch_months(%{year: year}, %{from_date: from, to_date: to}) do
    cond do
      year == from.year -> Range.new(from.month, 12)
      year == to.year -> Range.new(1, to.month)
      true -> Range.new(1, 12)
    end
  end

  defp fetch_years(%{from_date: from, to_date: to}), do: Range.new(from.year, to.year)

  defp format_day(day), do: String.pad_leading(Integer.to_string(day), 2, "0")
end
