defmodule HealthBoard.Scripts.Morbidities.Immediates.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoard.Scripts.Morbidities.Immediates

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @temporary_dir Path.join(@dir, "temp")

  @resident_location_context 0
  @source_location_context 1

  @spec age_groups :: list(atom())
  def age_groups do
    [
      :age_0_4,
      :age_5_9,
      :age_10_14,
      :age_15_19,
      :age_20_24,
      :age_25_29,
      :age_30_34,
      :age_35_39,
      :age_40_44,
      :age_45_49,
      :age_50_54,
      :age_55_59,
      :age_60_64,
      :age_64_69,
      :age_70_74,
      :age_75_79,
      :age_80_or_more,
      :ignored_age_group
    ]
  end

  @spec identify_age_group(String.t()) :: atom()
  def identify_age_group(age_code) do
    if age_code != "" do
      age_code = String.to_integer(age_code)

      cond do
        age_code <= 4004 -> :age_0_4
        age_code <= 4009 -> :age_5_9
        age_code <= 4014 -> :age_10_14
        age_code <= 4019 -> :age_15_19
        age_code <= 4024 -> :age_20_24
        age_code <= 4029 -> :age_25_29
        age_code <= 4034 -> :age_30_34
        age_code <= 4039 -> :age_35_39
        age_code <= 4044 -> :age_40_44
        age_code <= 4049 -> :age_45_49
        age_code <= 4054 -> :age_50_54
        age_code <= 4059 -> :age_55_59
        age_code <= 4064 -> :age_60_64
        age_code <= 4069 -> :age_64_69
        age_code <= 4074 -> :age_70_74
        age_code <= 4079 -> :age_75_79
        true -> :age_80_or_more
      end
    else
      :ignored_age_group
    end
  end

  @spec classifications :: list(atom())
  def classifications do
    [:confirmed, :discarded, :ignored_classification]
  end

  @spec identify_classification(String.t()) :: atom()
  def identify_classification(classification) do
    case classification do
      "1" -> :confirmed
      "2" -> :discarded
      _classification -> :ignored_classification
    end
  end

  @spec evolutions :: list(atom())
  def evolutions do
    [:healed, :died_from_disease, :died_from_other_causes, :ignored_evolution]
  end

  @spec identify_evolution(String.t()) :: atom()
  def identify_evolution(evolution) do
    case evolution do
      "1" -> :healed
      "2" -> :died_from_disease
      "3" -> :died_from_other_causes
      _evolution -> :ignored_evolution
    end
  end

  @spec races :: list(atom())
  def races do
    [:race_caucasian, :race_african, :race_asian, :race_brown, :race_native, :ignored_race]
  end

  @spec identify_race(String.t()) :: atom()
  def identify_race(race) do
    case race do
      "1" -> :race_caucasian
      "2" -> :race_african
      "3" -> :race_asian
      "4" -> :race_brown
      "5" -> :race_native
      _race -> :ignored_race
    end
  end

  @spec sex :: list(atom())
  def sex do
    [:male, :female, :ignored_sex]
  end

  @spec identify_sex(String.t()) :: atom()
  def identify_sex(sex) do
    case sex do
      "M" -> :male
      "F" -> :female
      _sex -> :ignored_sex
    end
  end

  @spec sex_age_groups :: list(atom())
  def sex_age_groups do
    [
      :age_0_4_male,
      :age_5_9_male,
      :age_10_14_male,
      :age_15_19_male,
      :age_20_24_male,
      :age_25_29_male,
      :age_30_34_male,
      :age_35_39_male,
      :age_40_44_male,
      :age_45_49_male,
      :age_50_54_male,
      :age_55_59_male,
      :age_60_64_male,
      :age_64_69_male,
      :age_70_74_male,
      :age_75_79_male,
      :age_80_or_more_male,
      :age_0_4_female,
      :age_5_9_female,
      :age_10_14_female,
      :age_15_19_female,
      :age_20_24_female,
      :age_25_29_female,
      :age_30_34_female,
      :age_35_39_female,
      :age_40_44_female,
      :age_45_49_female,
      :age_50_54_female,
      :age_55_59_female,
      :age_60_64_female,
      :age_64_69_female,
      :age_70_74_female,
      :age_75_79_female,
      :age_80_or_more_female,
      :ignored_sex_age_group
    ]
  end

  @spec identify_sex_age_group(atom() | String.t(), atom() | String.t()) :: atom()
  def identify_sex_age_group(sex, age_group) when is_atom(sex) and is_atom(age_group) do
    if sex != :ignored_sex and age_group != :ignored_age_group do
      String.to_atom("#{age_group}_#{sex}")
    else
      :ignored_sex_age_group
    end
  end

  def identify_sex_age_group(sex, age_group) do
    identify_sex_age_group(identify_sex(sex), identify_age_group(age_group))
  end

  @spec playbook :: :ok
  def playbook do
    Immediates.BotulismConsolidator.run()
    Immediates.ChikungunyaConsolidator.run()
    Immediates.CholeraConsolidator.run()
    Immediates.HantavirusConsolidator.run()
    Immediates.HumanRabiesConsolidator.run()
    Immediates.MalariaFromExtraAmazonConsolidator.run()
    Immediates.PlagueConsolidator.run()
    Immediates.SpottedFeverConsolidator.run()
    Immediates.YellowFeverConsolidator.run()
    Immediates.ZikaConsolidator.run()
  end

  @spec run(String.t(), function()) :: :ok
  def run(name, parse_function) do
    Logger.info("Consolidating #{name}")

    File.rm_rf!(@temporary_dir)

    cities = get_cities()

    @input_dir
    |> Path.join("#{name}.csv")
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> Task.async_stream(&parse_and_append_to_buckets(&1, cities, parse_function), timeout: :infinity)
    |> Stream.run()

    [
      fn -> consolidate(name, "yearly", &do_consolidate/5) end,
      fn -> consolidate(name, "weekly", &do_consolidate/5) end,
      fn -> consolidate(name, "periods", &write_period/5) end
    ]
    |> Task.async_stream(& &1.(), timeout: :infinity)
    |> Stream.run()

    :ok
  end

  defp get_cities do
    for %{id: id, parent_id: parent_id} <- Locations.list_by(level: Locations.city_level()), into: %{} do
      {"#{div(id, 10)}", %{id: id, parent_id: parent_id}}
    end
  end

  defp parse_and_append_to_buckets({line, line_index}, cities, parse_function) do
    if rem(line_index, 100_000) == 0 do
      Logger.info("Parsing line #{line_index}")
    end

    line
    |> parse_function.()
    |> append_to_buckets(cities)
  end

  defp append_to_buckets({resident_city_id, source_city_id, date, fields}, cities) do
    date = Date.from_iso8601!(date)

    @resident_location_context
    |> do_append_to_buckets(resident_city_id, date, fields, cities)
    |> Kernel.++(do_append_to_buckets(@source_location_context, source_city_id, date, fields, cities))
    |> Task.async_stream(& &1.(), timeout: :infinity)
    |> Stream.run()
  end

  defp do_append_to_buckets(location_context, city_id, date, fields, cities) do
    case find_city(cities, city_id) do
      %{id: city_id, parent_id: health_region_id} ->
        [
          fn -> append_to_yearly_bucket(location_context, health_region_id, city_id, date, fields) end,
          fn -> append_to_weekly_bucket(location_context, health_region_id, city_id, date, fields) end,
          fn -> update_periods_bucket(location_context, health_region_id, city_id, date) end
        ]

      nil ->
        []
    end
  end

  defp find_city(cities, city_id) do
    city_id = String.slice(city_id, 0, 6)
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id
    Map.get(cities, city_id)
  end

  defp append_to_yearly_bucket(location_context, health_region_id, city_id, %{year: year}, fields) do
    @temporary_dir
    |> Path.join("yearly")
    |> location_path(location_context, health_region_id, city_id)
    |> Path.join("#{year}")
    |> append_to_bucket(fields)
  end

  defp location_path(path, location_context, health_region_id, city_id) do
    path
    |> Path.join("#{location_context}")
    |> Path.join("76")
    |> Path.join("#{div(city_id, 1_000_000)}")
    |> Path.join("#{div(city_id, 100_000)}")
    |> Path.join("#{health_region_id}")
    |> Path.join("#{city_id}")
  end

  defp append_to_weekly_bucket(location_context, health_region_id, city_id, date, fields) do
    {year, week} = :calendar.iso_week_number(Date.to_erl(date))

    @temporary_dir
    |> Path.join("weekly")
    |> location_path(location_context, health_region_id, city_id)
    |> Path.join("#{year}_#{week}")
    |> append_to_bucket(fields)
  end

  defp update_periods_bucket(location_context, health_region_id, city_id, date) do
    @temporary_dir
    |> Path.join("periods")
    |> location_path(location_context, health_region_id, city_id)
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
    |> Stream.map(&consolidate_location_context(&1, path, output_file_path, function))
    |> Stream.run()

    sort_file(output_file_path)
  end

  defp fetch_output_file_path(name) do
    path = Path.join(@output_dir, name)
    File.rm_rf!(path)
    File.mkdir_p!(@output_dir)
    path
  end

  defp consolidate_location_context(location_context, path, output_file_path, function) do
    path = Path.join(path, location_context)

    path
    |> File.ls!()
    |> Stream.map(&consolidate(&1, location_context, path, output_file_path, function))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate(value, previous_value \\ nil, location_context, path, output_file_path, function) do
    path = Path.join(path, value)

    if File.dir?(path) do
      path
      |> File.ls!()
      |> Stream.map(&consolidate(&1, value, location_context, path, output_file_path, function))
      |> Stream.run()

      if String.length(value) != 7 do
        path
        |> File.ls!()
        |> Task.async_stream(&consolidate(&1, value, location_context, path, output_file_path, function),
          timeout: :infinity
        )
        |> Stream.run()
      end

      File.rm_rf!(path)
    else
      function.(value, previous_value, location_context, path, output_file_path)
    end
  end

  defp do_consolidate(value, previous_value, location_context, path, output_file_path) do
    path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, previous_value, value, path, output_file_path)
  end

  defp add_each(fields_1, nil) do
    Enum.map(fields_1, &String.to_integer/1)
  end

  defp add_each(fields_1, fields_2) do
    fields_1
    |> Enum.zip(fields_2)
    |> Enum.map(fn {field_1, field_2} -> String.to_integer(field_1) + field_2 end)
  end

  defp write_to_files(fields, location_context, location_id, year_or_week, path, output_file_path) do
    fields = Enum.join(fields, ",") <> "\n"

    line = Enum.join([location_context, location_id] ++ fetch_year_or_week(year_or_week), ",") <> ",#{fields}"
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

  defp write_period(value, previous_value, location_context, path, output_file_path) do
    path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(["9999-99-99", "0000-00-00"], &min_and_max/2)
    |> write_to_files(location_context, previous_value, value, path, output_file_path)
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
