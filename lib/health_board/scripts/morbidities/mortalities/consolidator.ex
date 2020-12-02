defmodule HealthBoard.Scripts.Morbidities.Mortalities.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoard.Scripts.Morbidities.Mortalities

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @temporary_dir Path.join(@dir, "temp")

  @spec find_city(map(), String.t()) :: %{id: integer(), parent_id: integer()} | nil
  def find_city(cities, city_id) do
    city_id = String.slice(city_id, 0, 6)
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id
    Map.get(cities, city_id)
  end

  @spec identify_age_group(String.t()) :: atom()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def identify_age_group(age_code) do
    if age_code != "" do
      age_code = String.to_integer(age_code)

      cond do
        age_code <= 404 -> :age_0_4
        age_code <= 409 -> :age_5_9
        age_code <= 414 -> :age_10_14
        age_code <= 419 -> :age_15_19
        age_code <= 424 -> :age_20_24
        age_code <= 429 -> :age_25_29
        age_code <= 434 -> :age_30_34
        age_code <= 439 -> :age_35_39
        age_code <= 444 -> :age_40_44
        age_code <= 449 -> :age_45_49
        age_code <= 454 -> :age_50_54
        age_code <= 459 -> :age_55_59
        age_code <= 464 -> :age_60_64
        age_code <= 469 -> :age_64_69
        age_code <= 474 -> :age_70_74
        age_code <= 479 -> :age_75_79
        true -> :age_80_or_more
      end
    else
      :ignored_age_group
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
      "1" -> :male
      "2" -> :female
      _sex -> :ignored_sex
    end
  end

  @spec playbook :: :ok
  def playbook do
    Mortalities.YearlyConsolidator.run()
  end

  @spec run(String.t(), function()) :: :ok
  def run(name, parse_function) do
    Logger.info("Consolidating #{name}")

    File.rm_rf!(@temporary_dir)

    output_file_path = Path.join(@output_dir, "yearly_#{name}_cases.csv")

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

    @temporary_dir
    |> File.ls!()
    |> Stream.map(&consolidate_disease_context(&1, output_file_path))
    |> Stream.run()

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

  defp do_append_to_buckets({disease_context, resident_city, source_city, year, fields}) do
    if year >= 2000 and year <= 2020 do
      unless is_nil(disease_context) do
        append_to_resident_buckets(disease_context, resident_city, source_city, year, fields)
      end

      append_to_resident_buckets(0, resident_city, source_city, year, fields)
    else
      Logger.warn("Ignoring non-desired year #{year}")
    end
  end

  defp append_to_resident_buckets(disease_context, resident_city, source_city, year, fields) do
    if is_map(resident_city) do
      health_region_id = resident_city.parent_id
      state_id = div(resident_city.id, 100_000)
      region_id = div(resident_city.id, 1_000_000)
      country_id = 76

      append_to_bucket(
        disease_context,
        0,
        resident_city.id,
        health_region_id,
        state_id,
        region_id,
        country_id,
        year,
        fields
      )
    end

    if is_map(source_city) do
      health_region_id = source_city.parent_id
      state_id = div(source_city.id, 100_000)
      region_id = div(source_city.id, 1_000_000)
      country_id = 76

      append_to_bucket(
        disease_context,
        1,
        source_city.id,
        health_region_id,
        state_id,
        region_id,
        country_id,
        year,
        fields
      )
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  defp append_to_bucket(
         disease_context,
         location_context,
         city_id,
         health_region_id,
         state_id,
         region_id,
         country_id,
         year,
         fields
       ) do
    path =
      @temporary_dir
      |> Path.join("#{disease_context}")
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

  defp consolidate_disease_context(disease_context, output_file_path) do
    Logger.info("Consolidating disease context #{disease_context}")

    path = Path.join(@temporary_dir, disease_context)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_location_context(&1, disease_context, path, output_file_path))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_location_context(location_context, disease_context, path, output_file_path) do
    Logger.info("Consolidating location context #{location_context}")

    path = Path.join(path, location_context)
    contexts = {disease_context, location_context}

    path
    |> File.ls!()
    |> Stream.map(&consolidate_country(&1, contexts, path, output_file_path))
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_country(country_id, contexts, path, output_file_path) do
    path = Path.join(path, country_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_region(&1, contexts, path, output_file_path))
    |> Stream.run()

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_year(&1, contexts, country_id, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_region(region_id, contexts, path, output_file_path) do
    Logger.info("Consolidating region #{region_id}")

    path = Path.join(path, region_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_state(&1, contexts, path, output_file_path))
    |> Stream.run()

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_year(&1, contexts, region_id, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_state(state_id, contexts, path, output_file_path) do
    path = Path.join(path, state_id)

    path
    |> File.ls!()
    |> Stream.map(&consolidate_health_region(&1, contexts, path, output_file_path))
    |> Stream.run()

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_year(&1, contexts, state_id, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_health_region(health_region_id, contexts, path, output_file_path) do
    path = Path.join(path, health_region_id)

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_city(&1, contexts, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_year(&1, contexts, health_region_id, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_city(city_id, contexts, path, output_file_path) do
    path = Path.join(path, city_id)

    path
    |> File.ls!()
    |> Task.async_stream(&consolidate_year(&1, contexts, city_id, path, output_file_path), timeout: :infinity)
    |> Stream.run()

    File.rm_rf!(path)
  end

  defp consolidate_year(year, {disease_context, location_context}, location_id, path, output_file_path) do
    path
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_files(disease_context, location_context, location_id, year, output_file_path, path)
  end

  defp add_each(fields_1, nil) do
    Enum.map(fields_1, &String.to_integer/1)
  end

  defp add_each(fields_1, fields_2) do
    fields_1
    |> Enum.zip(fields_2)
    |> Enum.map(fn {field_1, field_2} -> String.to_integer(field_1) + field_2 end)
  end

  defp write_to_files(fields, disease_context, location_context, location_id, year, output_file_path, path) do
    line =
      [
        String.to_integer(disease_context),
        String.to_integer(location_context),
        String.to_integer(location_id),
        String.to_integer(year)
      ] ++ fields

    File.write!(output_file_path, Enum.join(line, ",") <> "\n", [:append])

    if location_id != 76 do
      path
      |> Path.dirname()
      |> Path.join(year)
      |> File.write!(Enum.join(fields, ",") <> "\n", [:append])
    end
  end

  defp sort_file(file_path) do
    Logger.info("Sorting file #{file_path}")

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])
  end
end
