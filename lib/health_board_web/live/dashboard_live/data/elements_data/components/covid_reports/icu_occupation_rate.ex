defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.CovidReports.ICUOccupationRate do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.ElementsData.Components
  alias HealthBoardWeb.Helpers.{Charts, Choropleth, Humanize}

  # @label "Taxa de ocupação de leitos de UTI"
  @suffix "%"
  @param "icu_occupation_rates"
  @ranges [
    %{from: nil, to: 0, group: 0},
    %{from: 1, to: 49, group: :success},
    %{from: 50, to: 64, group: :warning},
    %{from: 65, to: 79, group: :alert},
    %{from: 80, to: 89, group: :danger},
    %{from: 90, to: nil, group: :critical}
  ]

  @spec choropleth_map(map, map) :: {:ok, tuple} | :error
  def choropleth_map(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @param) do
      if is_list(list) and Enum.any?(list) do
        Components.emit(%{
          ranges: @ranges,
          data: Enum.map(list, &wrap_map_item/1),
          suffix: @suffix,
          timestamp: :os.system_time()
        })
      else
        :error
      end
    end
  end

  defp wrap_map_item(%{location: %{id: id, name: name}, total: total}) do
    %{
      id: if(id > 1_000_000, do: Locations.state_id(id, :cities), else: id),
      name: name,
      value: Humanize.number(total),
      group: Choropleth.group(@ranges, total)
    }
  end

  @spec chart(map, map) :: {:ok, tuple} | :error
  def chart(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @param),
         {:ok, from_date} <- Components.fetch_data(data, params, "from_date"),
         {:ok, to_date} <- Components.fetch_data(data, params, "to_date") do
      if is_list(list) and Enum.any?(list) do
        date_range = Date.range(from_date, to_date)

        list
        |> Enum.group_by(& &1.location_id)
        |> Enum.with_index()
        |> Enum.map(&location_dataset(&1, date_range))
        |> Charts.line(Enum.to_list(date_range), show_legends?: true)
        |> Components.emit_and_hook("chart_data")
      else
        :error
      end
    end
  end

  defp location_dataset({{_location_id, [%{location: location} | _tail] = list}, index}, date_range) do
    list = Enum.sort(list, &(Date.compare(&1.date, &2.date) != :gt))
    {data, _list} = Enum.reduce(date_range, {[], list}, &location_date_rate/2)
    Charts.line_dataset(Enum.reverse(data), Humanize.location(location), colorize: :border, index: index)
  end

  defp location_date_rate(date, {result, list}) do
    if Enum.any?(list) do
      [%{date: record_date, total: total} | tail] = list

      case Date.compare(date, record_date) do
        :eq -> {[total | result], tail}
        :lt -> {[0 | result], list}
        :gt -> location_date_rate(date, {result, tail})
      end
    else
      {[0 | result], []}
    end
  end

  @spec heatmap_table(map, map) :: {:ok, tuple} | :error
  def heatmap_table(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @param),
         {:ok, from_date} <- Components.fetch_data(data, params, "from_date"),
         {:ok, to_date} <- Components.fetch_data(data, params, "to_date") do
      if is_list(list) and Enum.any?(list) do
        date_range = Date.range(from_date, to_date)

        lines =
          list
          |> Enum.group_by(& &1.location_id)
          |> Enum.map(&location_line(&1, date_range))

        %{lines: lines, headers: ["Localidade" | Enum.map(date_range, &Humanize.date(&1, format: :short))]}
        |> Components.emit()
      else
        :error
      end
    end
  end

  defp location_line({_location_id, [%{location: location} | _tail] = list}, date_range) do
    list = Enum.sort(list, &(Date.compare(&1.date, &2.date) != :gt))
    {cells, _list} = Enum.reduce(date_range, {[], list}, &location_cell/2)
    %{cells: [%{value: Humanize.location(location)} | Enum.reverse(cells)]}
  end

  defp location_cell(date, {result, list}) do
    if Enum.any?(list) do
      [%{date: record_date, total: total, values: link} | tail] = list

      case Date.compare(date, record_date) do
        :eq ->
          if is_nil(link) do
            {[%{value: total, group: Choropleth.group(@ranges, total)} | result], tail}
          else
            {[%{value: total, link: link, group: Choropleth.group(@ranges, total)} | result], tail}
          end

        :lt ->
          {[%{value: "N/A", group: 0} | result], list}

        :gt ->
          location_cell(date, {result, tail})
      end
    else
      {[%{value: "N/A", group: 0} | result], []}
    end
  end
end
