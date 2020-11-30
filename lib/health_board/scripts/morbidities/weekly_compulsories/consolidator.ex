defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoard.Scripts.Morbidities.WeeklyCompulsories

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @temporary_dir Path.join(@dir, "temp")

  @spec find_city(map(), String.t()) :: %{id: integer(), parent_id: integer()} | nil
  def find_city(cities, city_id) do
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id
    city = Map.get(cities, city_id)

    if is_nil(city) do
      Logger.warn("City with id #{city_id} not found")
    end

    city
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

  @spec identify_classification(String.t()) :: atom()
  def identify_classification(classification) do
    case classification do
      "1" -> :confirmed
      "2" -> :discarded
      _classification -> :ignored_classification
    end
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

  @spec identify_sex(String.t()) :: atom()
  def identify_sex(sex) do
    case sex do
      "M" -> :male
      "F" -> :female
      _sex -> :ignored_sex
    end
  end

  @spec playbook :: :ok
  def playbook do
    WeeklyCompulsories.AmericanTegumentaryLeishmaniasisConsolidator.run()
    WeeklyCompulsories.ChagasConsolidator.run()
    WeeklyCompulsories.DengueConsolidator.run()
    WeeklyCompulsories.DiphtheriaConsolidator.run()
    WeeklyCompulsories.ExogenousIntoxicationsConsolidator.run()
    WeeklyCompulsories.LeprosyConsolidator.run()
    WeeklyCompulsories.LeptospirosisConsolidator.run()
    WeeklyCompulsories.MeningitisConsolidator.run()
    WeeklyCompulsories.NeonatalTetanusConsolidator.run()
    WeeklyCompulsories.PoisonousAnimalsAccidentsConsolidator.run()
    WeeklyCompulsories.SchistosomiasisConsolidator.run()
    WeeklyCompulsories.TetanusAccidentsConsolidator.run()
    WeeklyCompulsories.TuberculosisConsolidator.run()
    WeeklyCompulsories.ViolenceConsolidator.run()
    WeeklyCompulsories.VisceralLeishmaniasisConsolidator.run()
    WeeklyCompulsories.WhoopingCoughConsolidator.run()
  end

  @spec run(String.t(), function()) :: :ok
  def run(name, parse_function) do
    Logger.info("Consolidating #{name}")

    File.rm_rf!(@temporary_dir)

    output_file_path = Path.join(@output_dir, "#{name}_yearly_cases.csv")

    File.rm_rf!(output_file_path)

    cities = get_cities()

    @input_dir
    |> Path.join("#{name}.csv")
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> Task.async_stream(&append_to_buckets(&1, cities, parse_function), timeout: :infinity)
    |> Stream.run()

    File.mkdir_p!(Path.dirname(output_file_path))

    file = File.open!(output_file_path, [:append])

    @temporary_dir
    |> File.ls!()
    |> Stream.map(&consolidate_context(&1, file))
    |> Stream.run()

    File.close(file)

    File.rm_rf!(@temporary_dir)

    sort_file(output_file_path)

    :ok
  end

  defp get_cities do
    for %{id: id, parent_id: parent_id} <- Locations.list_by(level: Locations.city_level()), into: %{} do
      {"#{div(id, 10)}", %{id: id, parent_id: parent_id}}
    end
  end

  defp append_to_buckets({line, line_index}, cities, parse_function) do
    if rem(line_index, 100_000) == 0 do
      Logger.info("Parsing line #{line_index}")
    end

    line
    |> parse_function.(cities)
    |> do_append_to_buckets()
  end

  defp do_append_to_buckets({resident_city, source_city, year, fields}) do
    if year >= 2000 and year <= 2020 do
      if is_map(resident_city) do
        health_region_id = resident_city.parent_id
        state_id = div(resident_city.id, 100_000)
        region_id = div(resident_city.id, 1_000_000)
        country_id = 76

        append_to_bucket(0, resident_city.id, health_region_id, state_id, region_id, country_id, year, fields)
      end

      if is_map(source_city) do
        health_region_id = source_city.parent_id
        state_id = div(source_city.id, 100_000)
        region_id = div(source_city.id, 1_000_000)
        country_id = 76

        append_to_bucket(1, source_city.id, health_region_id, state_id, region_id, country_id, year, fields)
      end
    else
      Logger.warn("Ignoring non-desired year #{year}")
    end
  end

  defp append_to_bucket(location_context, city_id, health_region_id, state_id, region_id, country_id, year, fields) do
    path =
      @temporary_dir
      |> Path.join("#{location_context}")
      |> Path.join("#{country_id}")
      |> Path.join("#{region_id}")
      |> Path.join("#{state_id}")
      |> Path.join("#{health_region_id}")
      |> Path.join("#{city_id}")
      |> Path.join("#{year}")

    File.mkdir_p!(Path.dirname(path))

    File.write!(path, Enum.join(fields, ",") <> "\n", [:append])
  end

  defp consolidate_context(location_context, file) do
    Logger.info("Consolidating location context #{location_context}")

    path = Path.join(@temporary_dir, location_context)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_country(&1, location_context, file))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_country(country_id, location_context, file) do
    path =
      @temporary_dir
      |> Path.join(location_context)
      |> Path.join(country_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_region(&1, country_id, location_context, file))
    |> Stream.run()

    path
    |> File.ls!()
    |> Stream.map(&consolidate_year(&1, country_id, location_context, file))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_region(region_id, country_id, location_context, file) do
    path =
      @temporary_dir
      |> Path.join(location_context)
      |> Path.join(country_id)
      |> Path.join(region_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_state(&1, region_id, country_id, location_context, file))
    |> Stream.run()

    path
    |> File.ls!()
    |> Stream.map(&consolidate_year(&1, region_id, country_id, location_context, file))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_state(state_id, region_id, country_id, location_context, file) do
    Logger.info("Consolidating state #{state_id}")

    path =
      @temporary_dir
      |> Path.join(location_context)
      |> Path.join(country_id)
      |> Path.join(region_id)
      |> Path.join(state_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_health_region(&1, state_id, region_id, country_id, location_context, file))
    |> Stream.run()

    path
    |> File.ls!()
    |> Stream.map(&consolidate_year(&1, state_id, region_id, country_id, location_context, file))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_health_region(health_region_id, state_id, region_id, country_id, location_context, file) do
    path =
      @temporary_dir
      |> Path.join(location_context)
      |> Path.join(country_id)
      |> Path.join(region_id)
      |> Path.join(state_id)
      |> Path.join(health_region_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_city(&1, health_region_id, state_id, region_id, country_id, location_context, file))
    |> Stream.run()

    path
    |> File.ls!()
    |> Stream.map(&consolidate_year(&1, health_region_id, state_id, region_id, country_id, location_context, file))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_city(city_id, health_region_id, state_id, region_id, country_id, location_context, file) do
    path =
      @temporary_dir
      |> Path.join(location_context)
      |> Path.join(country_id)
      |> Path.join(region_id)
      |> Path.join(state_id)
      |> Path.join(health_region_id)
      |> Path.join(city_id)

    path
    |> File.ls!()
    |> Stream.map(
      &consolidate_year(&1, city_id, health_region_id, state_id, region_id, country_id, location_context, file)
    )
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_year(year, country_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, country_id, year, file)
  end

  defp consolidate_year(year, region_id, country_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, country_id, region_id, year, file)
  end

  defp consolidate_year(year, state_id, region_id, country_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(state_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, country_id, region_id, state_id, year, file)
  end

  defp consolidate_year(year, health_region_id, state_id, region_id, country_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(state_id)
    |> Path.join(health_region_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, country_id, region_id, state_id, health_region_id, year, file)
  end

  defp consolidate_year(year, city_id, health_region_id, state_id, region_id, country_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(state_id)
    |> Path.join(health_region_id)
    |> Path.join(city_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(location_context, country_id, region_id, state_id, health_region_id, city_id, year, file)
  end

  defp add_each(fields_1, nil) do
    Enum.map(fields_1, &String.to_integer/1)
  end

  defp add_each(fields_1, fields_2) do
    fields_1
    |> Enum.zip(fields_2)
    |> Enum.map(fn {field_1, field_2} -> String.to_integer(field_1) + field_2 end)
  end

  defp write_to_files(fields, location_context, country_id, year, file) do
    write_to_file(fields, location_context, country_id, year, file)
  end

  defp write_to_files(fields, location_context, country_id, region_id, year, file) do
    write_to_file(fields, location_context, region_id, year, file)

    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(year)
    |> File.write!(Enum.join(fields, ",") <> "\n", [:append])
  end

  defp write_to_files(fields, location_context, country_id, region_id, state_id, year, file) do
    write_to_file(fields, location_context, state_id, year, file)

    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(year)
    |> File.write!(Enum.join(fields, ",") <> "\n", [:append])
  end

  defp write_to_files(fields, location_context, country_id, region_id, state_id, health_region_id, year, file) do
    write_to_file(fields, location_context, health_region_id, year, file)

    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(state_id)
    |> Path.join(year)
    |> File.write!(Enum.join(fields, ",") <> "\n", [:append])
  end

  defp write_to_files(fields, location_context, country_id, region_id, state_id, health_region_id, city_id, year, file) do
    write_to_file(fields, location_context, city_id, year, file)

    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(country_id)
    |> Path.join(region_id)
    |> Path.join(state_id)
    |> Path.join(health_region_id)
    |> Path.join(year)
    |> File.write!(Enum.join(fields, ",") <> "\n", [:append])
  end

  defp write_to_file(fields, location_context, location_id, year, file) do
    line = [String.to_integer(location_context), String.to_integer(location_id), String.to_integer(year)] ++ fields

    IO.write(file, Enum.join(line, ",") <> "\n")
  end

  defp sort_file(file_path) do
    Logger.info("Sorting file #{file_path}")

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])
  end
end
