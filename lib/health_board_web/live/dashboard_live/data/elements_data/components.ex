defmodule HealthBoardWeb.DashboardLive.ElementsData.Components do
  alias HealthBoardWeb.Helpers.{Charts, Choropleth, Humanize, Math}

  @spec apply_in_total_per_location(list(map), list(map), (integer, integer -> number)) :: list(map)
  def apply_in_total_per_location(l1, l2, function) do
    {list, _l2} = Enum.reduce(l1, {[], l2}, &do_apply_in_total_per_location(&1, &2, function))
    Enum.reverse(list)
  end

  defp do_apply_in_total_per_location(%{location_id: location_id, total: t1} = s1, {list, l2}, function) do
    {t2, l2} = pop_total_from_location(l2, location_id)
    {[Map.put(s1, :total, function.(t1, t2)) | list], l2}
  end

  defp pop_total_from_location(list, location_id) do
    Enum.reduce(list, {nil, []}, fn
      %{location_id: ^location_id, total: total}, {nil, list} -> {total, list}
      s2, {total, list} -> {total, [s2 | list]}
    end)
  end

  @spec choropleth_maps(String.t(), (atom -> {:ok, {list(map), list(number)}} | :error)) :: {:ok, tuple} | :error
  def choropleth_maps(suffix, data_function) do
    %{}
    |> maybe_put_map_data(:regions_data, locations_data(:regions, suffix, data_function))
    |> maybe_put_map_data(:states_data, locations_data(:states, suffix, data_function))
    |> maybe_put_map_data(:health_regions_data, locations_data(:health_regions, suffix, data_function))
    |> maybe_put_map_data(:cities_data, locations_data(:cities, suffix, data_function))
    |> validate_map_data()
    |> case do
      {:ok, data} -> emit(data)
      :error -> :error
    end
  end

  defp locations_data(prefix, suffix, data_function) do
    with {:ok, {map_data, rates}} <- data_function.(prefix) do
      ranges = Choropleth.weighted_distribution(rates)

      {:ok,
       %{
         ranges: ranges,
         data: Enum.map(map_data, &wrap_map_item(&1, ranges)),
         suffix: suffix,
         timestamp: :os.system_time()
       }}
    end
  end

  defp wrap_map_item(%{value: value} = item, ranges) do
    Map.merge(item, %{value: Humanize.number(value), group: Choropleth.group(ranges, value)})
  end

  defp maybe_put_map_data(map, key, {:ok, map_data}), do: Map.put(map, key, map_data)
  defp maybe_put_map_data(map, _key, _result), do: map

  defp validate_map_data(map_data) do
    if Enum.any?(map_data) do
      {:ok, Map.put(map_data, :length, length(Map.keys(map_data)))}
    else
      :error
    end
  end

  @spec daily_epicurve(list(map), String.t()) :: {:ok, tuple} | :error
  def daily_epicurve(list, label) do
    case list do
      [_, _ | _] ->
        date_range = date_range(list)
        data = total_per_date(list, date_range)
        trend = Math.moving_average(data)

        data =
          [
            %{
              type: "line",
              label: "Tendência (Média móvel de 7 dias)",
              backgroundColor: "#000",
              borderColor: "#000",
              borderWidth: 2,
              pointRadius: 1,
              fill: false,
              data: trend
            },
            %{
              type: "bar",
              label: label,
              backgroundColor: "rgba(54, 162, 235, 0.2)",
              borderColor: "#36a2eb",
              pointRadius: 2,
              borderWidth: 3,
              fill: false,
              data: data
            }
          ]
          |> Charts.combo("Data", Enum.to_list(date_range))

        emit_and_hook({"chart_data", data})

      _list ->
        :error
    end
  end

  @spec date_range(list(map)) :: Date.Range.t()
  def date_range(list) do
    {from, to} = Enum.reduce(list, nil, &date_min_and_max/2)
    Date.range(from, to)
  end

  defp date_min_and_max(%{date: date}, nil), do: {date, date}
  defp date_min_and_max(%{date: date}, {from, to}), do: {date_min(date, from), date_max(date, to)}
  defp date_min(d1, d2), do: if(Date.compare(d1, d2) == :gt, do: d2, else: d1)
  defp date_max(d1, d2), do: if(Date.compare(d1, d2) == :lt, do: d2, else: d1)

  @spec emit(map) :: {:ok, {:emit, map}}
  def emit(data), do: {:ok, {:emit, data}}

  @spec emit_and_hook({map, String.t(), map} | {String.t(), map}) ::
          {:ok, {:emit_and_hook, {map, String.t(), map} | {String.t(), map}}}
  def emit_and_hook(data), do: {:ok, {:emit_and_hook, data}}

  @spec emit_and_hook(map, String.t()) :: {:ok, {:emit_and_hook, {String.t(), map}}}
  def emit_and_hook(data, hook), do: {:ok, {:emit_and_hook, {hook, data}}}

  @spec fetch_data(map, map, String.t(), keyword) :: {:ok, any} | :error
  def fetch_data(data, params, key, _opts \\ []), do: Map.fetch(data, String.to_atom(params[key] || key))

  @spec monthly_chart(list(map), String.t()) :: {:ok, tuple} | :error
  def monthly_chart(list, label) do
    case list do
      [_, _ | _] ->
        yearmonths = fetch_yearmonths(list)
        datasets = [Charts.line_dataset(total_per_month(list, yearmonths), label)]
        emit_and_hook({"chart_data", Charts.line(datasets, Enum.map(yearmonths, fn {y, m} -> "#{y}-#{m}" end))})

      _list ->
        :error
    end
  end

  defp fetch_yearmonths(list) do
    {{fy, fm}, {ty, tm}} = Enum.reduce(list, nil, &month_min_and_max/2)

    for year <- fy..ty, month <- 1..12 do
      if (year == fy and month < fm) or (year == ty and month > tm) do
        nil
      else
        {year, month}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp month_min_and_max(%{year: year, month: month}, boundary) do
    if is_nil(boundary) do
      {{year, month}, {year, month}}
    else
      {{fy, fm}, {ty, tm}} = boundary
      {month_min(year, month, fy, fm), month_max(year, month, ty, tm)}
    end
  end

  defp month_min(y1, m1, y2, m2) do
    cond do
      y1 > y2 -> {y2, m2}
      y1 < y2 -> {y1, m1}
      m1 > m2 -> {y2, m2}
      m1 < m2 -> {y1, m1}
      true -> {y1, m1}
    end
  end

  defp month_max(y1, m1, y2, m2) do
    cond do
      y1 < y2 -> {y2, m2}
      y1 > y2 -> {y1, m1}
      m1 < m2 -> {y2, m2}
      m1 > m2 -> {y1, m1}
      true -> {y1, m1}
    end
  end

  @per_age_gender_labels [
    "80 anos ou mais",
    "Entre 75 e 79 anos",
    "Entre 70 e 74 anos",
    "Entre 65 e 69 anos",
    "Entre 60 e 64 anos",
    "Entre 55 e 59 anos",
    "Entre 50 e 54 anos",
    "Entre 45 e 49 anos",
    "Entre 40 e 44 anos",
    "Entre 35 e 39 anos",
    "Entre 30 e 34 anos",
    "Entre 25 e 29 anos",
    "Entre 20 e 24 anos",
    "Entre 15 e 19 anos",
    "Entre 10 e 14 anos",
    "Entre 5 e 9 anos",
    "Entre 0 e 4 anos"
  ]

  @spec per_age_gender(list) :: {:ok, tuple} | :error
  def per_age_gender(list) do
    if is_list(list) and length(list) == 34 do
      {negative_data, positive_data} = Enum.split(Enum.reverse(list), 17)

      {
        "chart_data",
        Charts.pyramid_bar(positive_data, negative_data, "Feminino", "Masculino", @per_age_gender_labels)
      }
      |> emit_and_hook()
    else
      :error
    end
  end

  @per_comorbidity_labels [
    "Asma",
    "Doença cardiovascular crônica",
    "Doença hematológica crônica",
    "Doença renal crônica",
    "Doença hepática crônica",
    "Doença neurológica crônica",
    "Doença pneumatopatia crônica",
    "Diabetes Mellitus",
    "Síndrome de Down",
    "Imunodeficiência ou imunodepressão",
    "Obesidade",
    "Puérpera"
  ]

  @spec per_comorbidity(list, String.t()) :: {:ok, tuple} | :error
  def per_comorbidity(list, label) do
    if is_list(list) and length(list) == 12 do
      emit_and_hook({"chart_data", Charts.vertical_bar(list, label, @per_comorbidity_labels)})
    else
      :error
    end
  end

  @per_race_labels [
    "Branca",
    "Preta",
    "Amarela",
    "Parda",
    "Indígena",
    "Ignorada"
  ]

  @spec per_race(list, String.t()) :: {:ok, tuple} | :error
  def per_race(list, label) do
    if is_list(list) and length(list) == 6 do
      emit_and_hook({"chart_data", Charts.vertical_bar(list, label, @per_race_labels)})
    else
      :error
    end
  end

  @per_symptom_labels [
    "Dor abdominal",
    "Tosse",
    "Diárreia",
    "Dispneia",
    "Fadiga",
    "Febre",
    "Desconforto respiratório",
    "Saturação oxigênio abaixo de 95%",
    "Perda de olfato",
    "Dor de garganta",
    "Perda de paladar",
    "Vômito"
  ]

  @spec per_symptom(list, String.t()) :: {:ok, tuple} | :error
  def per_symptom(list, label) do
    if is_list(list) and length(list) == 12 do
      emit_and_hook({"chart_data", Charts.vertical_bar(list, label, @per_symptom_labels)})
    else
      :error
    end
  end

  @spec pop_with_location_id(list(map), integer) :: {map, list(map)}
  def pop_with_location_id(list, location_id) do
    Enum.reduce(list, {nil, []}, fn
      %{location_id: ^location_id} = schema, {nil, list} -> {schema, list}
      schema, {result, list} -> {result, [schema | list]}
    end)
  end

  @spec scalar(number) :: {:ok, tuple} | :error
  def scalar(number) do
    if is_number(number) do
      emit(%{value: Humanize.number(number)})
    else
      :error
    end
  end

  @spec sum_total_per_date(list(map), list(map)) :: list(map)
  def sum_total_per_date(l1, l2) do
    {result, _l2} =
      Enum.reduce(l1, {[], l2}, fn %{date: d1, total: t1} = s1, {result, l2} ->
        {t2, l2} =
          Enum.reduce(l2, {nil, []}, fn
            %{date: ^d1, total: t2}, {nil, l2} -> {t2, l2}
            s2, {t2, l2} -> {t2, [s2 | l2]}
          end)

        {[Map.put(s1, :total, t1 + (t2 || 0)) | result], l2}
      end)

    Enum.reverse(result)
  end

  @spec sum_total_per_location(list(map), list(map)) :: list(map)
  def sum_total_per_location(l1, l2) do
    {result, _l2} =
      Enum.reduce(l1, {[], l2}, fn %{location_id: location_id, total: t1} = s1, {result, l2} ->
        {t2, l2} =
          Enum.reduce(l2, {nil, []}, fn
            %{location_id: ^location_id, total: t2}, {nil, l2} -> {t2, l2}
            s2, {t2, l2} -> {t2, [s2 | l2]}
          end)

        {[Map.put(s1, :total, t1 + (t2 || 0)) | result], l2}
      end)

    Enum.reverse(result)
  end

  @spec top_ten_locations_table(list(map)) :: {:ok, tuple} | :error
  def top_ten_locations_table([_ | _] = list), do: emit(%{lines: top_ten_table_lines(list)})
  def top_ten_locations_table(_list), do: :error

  defp top_ten_table_lines(list) do
    list
    |> Enum.sort(&(&1.total >= &2.total))
    |> Enum.slice(0, 10)
    |> Enum.map(&top_ten_table_line/1)
  end

  defp top_ten_table_line(%{location: location, total: total}) do
    %{cells: [%{value: Humanize.location(location), link: %{location: location.id}}, %{value: Humanize.number(total)}]}
  end

  @spec total_per_date(list(map), Enum.t()) :: list(map)
  def total_per_date(list, date_range) do
    {result, _list} =
      Enum.reduce(date_range, {[], list}, fn date, {result, list} ->
        {total, list} =
          Enum.reduce(list, {nil, []}, fn
            %{date: ^date, total: total}, {nil, list} -> {total, list}
            item, {total, list} -> {total, [item | list]}
          end)

        {[total || 0 | result], list}
      end)

    Enum.reverse(result)
  end

  @spec total_per_month(list(map), Enum.t()) :: list(map)
  def total_per_month(list, yearmonths) do
    {result, _list} =
      Enum.reduce(yearmonths, {[], list}, fn {year, month}, {result, list} ->
        {total, list} =
          Enum.reduce(list, {nil, []}, fn
            %{year: ^year, month: ^month, total: total}, {nil, list} -> {total, list}
            item, {total, list} -> {total, [item | list]}
          end)

        {[total || 0 | result], list}
      end)

    Enum.reverse(result)
  end

  @spec total_per_week(list(map), Enum.t()) :: list(map)
  def total_per_week(list, yearweeks) do
    {result, _list} =
      Enum.reduce(yearweeks, {[], list}, fn {year, week}, {result, list} ->
        {total, list} =
          Enum.reduce(list, {nil, []}, fn
            %{year: ^year, week: ^week, total: total}, {nil, list} -> {total, list}
            item, {total, list} -> {total, [item | list]}
          end)

        {[total || 0 | result], list}
      end)

    Enum.reverse(result)
  end

  @spec weekly_chart(list(map), String.t()) :: {:ok, tuple} | :error
  def weekly_chart(list, label) do
    case list do
      [_, _ | _] ->
        yearweeks = fetch_yearweeks(list)
        datasets = [Charts.line_dataset(total_per_week(list, yearweeks), label)]
        emit_and_hook({"chart_data", Charts.line(datasets, Enum.map(yearweeks, fn {y, m} -> "#{y}-#{m}" end))})

      _list ->
        :error
    end
  end

  defp fetch_yearweeks(list) do
    {{fy, fw}, {ty, tw}} = Enum.reduce(list, nil, &week_min_and_max/2)

    for year <- fy..ty, week <- 1..53 do
      if (year == fy and week < fw) or (year == ty and week > tw) do
        nil
      else
        {year, week}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp week_min_and_max(%{year: year, week: week}, boundary) do
    if is_nil(boundary) do
      {{year, week}, {year, week}}
    else
      {{fy, fw}, {ty, tw}} = boundary
      {week_min(year, week, fy, fw), week_max(year, week, ty, tw)}
    end
  end

  defp week_min(y1, w1, y2, w2) do
    cond do
      y1 > y2 -> {y2, w2}
      y1 < y2 -> {y1, w1}
      w1 > w2 -> {y2, w2}
      w1 < w2 -> {y1, w1}
      true -> {y1, w1}
    end
  end

  defp week_max(y1, w1, y2, w2) do
    cond do
      y1 < y2 -> {y2, w2}
      y1 > y2 -> {y1, w1}
      w1 < w2 -> {y2, w2}
      w1 > w2 -> {y1, w1}
      true -> {y1, w1}
    end
  end
end
