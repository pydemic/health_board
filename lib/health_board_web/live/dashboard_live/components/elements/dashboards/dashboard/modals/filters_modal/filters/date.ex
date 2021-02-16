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
    filter = assigns.filter
    options = filter.options

    date = assigns.date || Map.get_lazy(filter, :value, fn -> Date.utc_today() end)

    days = assigns.days || fetch_days(date, options)
    months = assigns.months || fetch_months(date, options)
    years = assigns.years || fetch_years(options)

    ~H"""
    <div class="bg-gray-50 px-5 pb-5 rounded-lg">
      <Form :if={{ @filter.disabled != true }} for={{ :date }} change="change">
        <div class="grid md:grid-cols-3 gap-2 place-items-stretch">
          <Select name="day" label="Dia" selected={{ date.day }} options={{ days }} formatter={{ &format_day/1 }} />
          <Select name="month" label="Mês" selected={{ date.month }} options={{ months }} formatter={{ &format_day/1 }} />
          <Select name="year" label="Ano" selected={{ date.year }} options={{ years }} />
        </div>
      </Form>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("change", %{"day" => day, "month" => month, "year" => year}, %{assigns: assigns} = socket) do
    case Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)) do
      {:ok, date} ->
        if Date.compare(assigns.filter.value, date) != :eq do
          FiltersModal.update_changes(Map.put(assigns.changes, "date", Date.to_iso8601(date)))
        else
          FiltersModal.update_changes(Map.delete(assigns.changes, "date"))
        end

        {:noreply, LiveView.assign(socket, :date, date)}

      _error ->
        {:noreply, socket}
    end
  end

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
