defmodule HealthBoard.DataPuller.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations

  @dir Path.join(File.cwd!(), ".misc/sandbox/smallbox")
  @input_dir Path.join(@dir, "output")
  @output_dir Path.join(@dir, "output_consolidated")

  @city Locations.context!(:city)
  @health_region Locations.context!(:health_region)
  @buckets {{%{}, %{}, %{}, %{}}, {%{}, %{}, %{}, %{}}}

  @fields [
    :confirmed,
    :discarded,
    :male_0_4,
    :male_5_9,
    :male_10_14,
    :male_15_19,
    :male_20_24,
    :male_25_29,
    :male_30_34,
    :male_35_39,
    :male_40_44,
    :male_45_49,
    :male_50_54,
    :male_55_59,
    :male_60_64,
    :male_64_69,
    :male_70_74,
    :male_75_79,
    :male_80_or_more,
    :female_0_4,
    :female_5_9,
    :female_10_14,
    :female_15_19,
    :female_20_24,
    :female_25_29,
    :female_30_34,
    :female_35_39,
    :female_40_44,
    :female_45_49,
    :female_50_54,
    :female_55_59,
    :female_60_64,
    :female_64_69,
    :female_70_74,
    :female_75_79,
    :female_80_or_more,
    :health_professional
  ]

  @spec run() :: :ok
  def run() do
    Logger.info("Consolidating tests of COVID-19")

    cities = get_cities()
    file_name = "dados-ac-20201215132054Z.csv.csv"

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    # |> Stream.take(20)
    |> Stream.with_index(1)
    |> Enum.reduce(@buckets, &parse_and_append_to_buckets(&1, &2, cities, file_name))

    # |> consolidate()

    :ok
  end

  defp get_cities do
    [context: @city]
    |> Locations.list_by()
    |> Locations.preload_parent(@health_region)
    |> Enum.map(&{&1.id, [&1.id, Enum.at(&1.parents, 0).parent_id, div(&1.id, 100_000), div(&1.id, 1_000_000)]})
    |> Enum.into(%{})
  end

  defp parse_and_append_to_buckets({line, line_index}, buckets, cities, file_name) do
    if rem(line_index, 100_000) == 0 do
      Logger.info("Parsing line #{line_index}")
    end

    line
    |> parse_line(cities)
    |> append_to_buckets(buckets)
  rescue
    error -> Logger.error("[#{file_name}:#{line_index}] #{Exception.message(error)}")
  end

  defp parse_line(line, cities) do
    [
      _id,
      date_symptoms,
      date_notification,
      age,
      professional_health,
      gender,
      test_result,
      final_classification,
      notification_city_id,
      residence_city_id
    ] = line

    date = identify_date!(date_symptoms, date_notification)

    notification_locations = identify_locations(notification_city_id, cities)
    residence_locations = identify_locations(residence_city_id, cities)

    if is_nil(notification_locations) and is_nil(residence_locations) do
      raise ~s(Invalid cities: "#{notification_city_id}" "#{residence_city_id}")
    end

    fields = [
      identify_gender_age_group(
        identify_gender(gender),
        identify_age_group(age)
      ),
      identify_classification(
        String.upcase(String.first(test_result) || ""),
        String.upcase(String.first(final_classification) || "")
      ),
      identify_health_professional(String.upcase(String.first(professional_health) || ""))
    ]

    {
      notification_locations,
      residence_locations,
      date,
      Enum.map(@fields, &if(&1 in fields, do: 1, else: 0))
    }
  end

  defp identify_date!(datetime_symptoms, datetime_notification) do
    case NaiveDateTime.from_iso8601(datetime_symptoms) do
      {:ok, datetime} -> datetime
      _error -> NaiveDateTime.from_iso8601!(datetime_notification)
    end
    |> NaiveDateTime.to_date()
  end

  defp identify_locations(city_id, cities) do
    Map.get(cities, String.to_integer(city_id))
  rescue
    _error -> nil
  end

  defp identify_gender_age_group(nil, _age_group), do: nil
  defp identify_gender_age_group(_gender, nil), do: nil
  defp identify_gender_age_group(gender, age_group), do: String.to_atom("#{gender}_#{age_group}")

  defp identify_gender(gender) do
    gender =
      gender
      |> String.first()
      |> String.upcase()

    case gender do
      "M" -> "male"
      "F" -> "female"
      _gender -> nil
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp identify_age_group(age) do
    if age != "" do
      age = String.to_integer(age)

      cond do
        age <= 4 -> "0_4"
        age <= 9 -> "5_9"
        age <= 14 -> "10_14"
        age <= 19 -> "15_19"
        age <= 24 -> "20_24"
        age <= 29 -> "25_29"
        age <= 34 -> "30_34"
        age <= 39 -> "35_39"
        age <= 44 -> "40_44"
        age <= 49 -> "45_49"
        age <= 54 -> "50_54"
        age <= 59 -> "55_59"
        age <= 64 -> "60_64"
        age <= 69 -> "64_69"
        age <= 74 -> "70_74"
        age <= 79 -> "75_79"
        true -> "80_or_more"
      end
    else
      nil
    end
  rescue
    _error -> nil
  end

  defp identify_classification("P", _tail_final_classification), do: :confirmed
  defp identify_classification(_test_result, "C"), do: :confirmed
  defp identify_classification(_test_result, _final_classification), do: :discarded

  defp identify_health_professional("S"), do: :health_professional
  defp identify_health_professional(_other), do: nil

  defp append_to_buckets({notification_locations, nil, date, fields}, buckets) do
    %{month: month} = date
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))
    {notification_buckets, residence_buckets} = buckets

    {do_append_to_buckets(notification_buckets, notification_locations, {date, year, week, month}, fields),
     residence_buckets}
  end

  defp append_to_buckets({nil, residence_locations, date, fields}, buckets) do
    %{month: month} = date
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))
    {notification_buckets, residence_buckets} = buckets

    {notification_buckets,
     do_append_to_buckets(residence_buckets, residence_locations, {date, year, week, month}, fields)}
  end

  defp append_to_buckets({notification_locations, residence_locations, date, fields}, buckets) do
    %{month: month} = date
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))
    {notification_buckets, residence_buckets} = buckets

    {do_append_to_buckets(notification_buckets, notification_locations, {date, year, week, month}, fields),
     do_append_to_buckets(residence_buckets, residence_locations, {date, year, week, month}, fields)}
  end

  defp do_append_to_buckets(buckets, locations, dates, fields) do
    {daily, weekly, monthly, pandemic} = buckets
    {city_id, parents} = locations
  end

  defp find_city(cities, city_id) do
    city_id = String.slice(city_id, 0, 6)
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id
    Map.get(cities, city_id)
  end

  defp append_to_yearly_bucket(health_region_id, city_id, %{year: year}, fields) do
    @temporary_dir
    |> Path.join("yearly")
    |> location_path(health_region_id, city_id)
    |> Path.join("#{year}")
    |> append_to_bucket(fields)
  end

  defp location_path(path, health_region_id, city_id) do
    path
    |> Path.join("76")
    |> Path.join("#{div(city_id, 1_000_000)}")
    |> Path.join("#{div(city_id, 100_000)}")
    |> Path.join("#{health_region_id}")
    |> Path.join("#{city_id}")
  end

  defp append_to_weekly_bucket(health_region_id, city_id, date, fields) do
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))

    @temporary_dir
    |> Path.join("weekly")
    |> location_path(health_region_id, city_id)
    |> Path.join("#{year}_#{week}")
    |> append_to_bucket(fields)
  end

  defp update_periods_bucket(health_region_id, city_id, date) do
    @temporary_dir
    |> Path.join("periods")
    |> location_path(health_region_id, city_id)
    |> Path.join("d")
    |> append_to_bucket([date])
  end

  defp append_to_bucket(path, fields) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, Enum.join(fields, ",") <> "\n", [:append])
  end

  defp consolidate(name, type, function) do
    output_file_path = fetch_output_file_path("#{name}_#{type}_cases.csv")
    path = Path.join(@temporary_dir, type)

    path
    |> File.ls!()
    |> Stream.map(consolidate_location(path, output_file_path, function))
    |> Stream.run()

    sort_file(output_file_path)
  end

  defp fetch_output_file_path(name) do
    path = Path.join(@output_dir, name)
    File.rm_rf!(path)
    File.mkdir_p!(@output_dir)
    path
  end

  defp consolidate_location(path, output_file_path, function) do
    path
    |> File.ls!()
    |> Stream.map(&consolidate(&1, path, output_file_path, function))
    |> Stream.run()

    # File.rm_rf!(path)
  end

  defp consolidate(
         value,
         previous_value \\ nil,
         path,
         output_file_path,
         function
       ) do
    path = Path.join(path, value)

    if File.dir?(path) do
      path
      |> File.ls!()
      |> Stream.map(&consolidate(&1, value, path, output_file_path, function))
      |> Stream.run()

      if String.length(value) != 7 do
        path
        |> File.ls!()
        |> Task.async_stream(
          &consolidate(&1, value, path, output_file_path, function),
          timeout: :infinity
        )
        |> Stream.run()
      end

      # File.rm_rf!(path)
    else
      function.(value, previous_value, path, output_file_path)
    end
  end

  defp do_consolidate(value, previous_value, path, output_file_path) do
    path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(previous_value, value, path, output_file_path)
  end

  defp add_each(fields_1, nil) do
    Enum.map(fields_1, &String.to_integer/1)
  end

  defp add_each(fields_1, fields_2) do
    fields_1
    |> Enum.zip(fields_2)
    |> Enum.map(fn {field_1, field_2} -> String.to_integer(field_1) + field_2 end)
  end

  defp write_to_files(fields, location_id, year_or_week, path, output_file_path) do
    fields = Enum.join(fields, ",") <> "\n"

    line =
      Enum.join([location_id] ++ fetch_year_or_week(year_or_week), ",") <>
        ",#{fields}"

    File.write!(output_file_path, line, [:append])

    if location_id != "76" do
      path
      |> Path.dirname()
      |> Path.dirname()
      |> Path.join(year_or_week)
      |> File.write!(fields, [:append])
    end
  end

  defp fetch_year_or_week(year_or_week) do
    case String.length(year_or_week) do
      1 -> []
      4 -> [year_or_week]
      _ -> String.split(year_or_week, "_")
    end
  end

  defp write_period(value, previous_value, path, output_file_path) do
    path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(["9999-99-99", "0000-00-00"], &min_and_max/2)
    |> write_to_files(previous_value, value, path, output_file_path)
  end

  defp min_and_max([date], [min, max]) do
    min = if date < min, do: date, else: min
    max = if date > max, do: date, else: max
    [min, max]
  end

  defp min_and_max([min1, max1], [min2, max2]) do
    min = if min1 < min2, do: min1, else: min2
    max = if max1 > max2, do: max1, else: max2
    [min, max]
  end

  defp sort_file(file_path) do
    Logger.info("Sorting file #{file_path}")

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])
  end
end
