defmodule HealthBoard.Scripts.Morbidities.Immediates.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoard.Scripts.Morbidities.Immediates

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @temporary_dir Path.join(@dir, "temp")

  @spec find_city(list(Locations.schema()), String.t()) :: Locations.schema() | nil
  def find_city(cities, city_id) do
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id

    case Enum.find(cities, &(div(&1.id, 10) == String.to_integer(city_id))) do
      nil ->
        Logger.warn("City with id #{city_id} not found")
        nil

      city ->
        city
    end
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
      "5" -> :race_indigenous
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

  @spec run(
          String.t(),
          (list(String.t()), list(Locations.schema()) ->
             {Locations.schema() | nil, Locations.schema() | nil, integer(), list(integer())})
        ) :: :ok
  def run(name, parse_function) do
    File.rm_rf!(@temporary_dir)

    output_file_path = Path.join(@output_dir, "#{name}_yearly_cases.csv")

    File.rm_rf!(output_file_path)

    cities = Locations.list_by(level: Locations.city_level())

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

  defp append_to_buckets({line, line_index}, cities, parse_function) do
    if rem(line_index, 100_000) == 0 do
      Logger.info("Parsing line #{line_index}")
    end

    line
    |> parse_function.(cities)
    |> do_append_to_buckets()
  end

  defp do_append_to_buckets({resident_city, source_city, year, fields}) do
    if is_map(resident_city) do
      append_to_bucket(0, resident_city.id, year, fields)
      append_to_bucket(0, resident_city.parent_id, year, fields)
      append_to_bucket(0, div(resident_city.id, 100_000), year, fields)
      append_to_bucket(0, div(resident_city.id, 1_000_000), year, fields)
      append_to_bucket(0, 76, year, fields)
    end

    if is_map(source_city) do
      append_to_bucket(1, source_city.id, year, fields)
      append_to_bucket(1, source_city.parent_id, year, fields)
      append_to_bucket(1, div(source_city.id, 100_000), year, fields)
      append_to_bucket(1, div(source_city.id, 1_000_000), year, fields)
      append_to_bucket(1, 76, year, fields)
    end
  end

  defp append_to_bucket(location_context, location_id, year, fields) do
    path =
      @temporary_dir
      |> Path.join("#{location_context}")
      |> Path.join("#{location_id}")
      |> Path.join("#{year}")

    File.mkdir_p!(Path.dirname(path))

    File.write!(path, Enum.join(fields, ",") <> "\n", [:append])
  end

  defp consolidate_context(location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> File.ls!()
    |> Stream.map(&consolidate_location(&1, location_context, file))
    |> Stream.run()
  end

  defp consolidate_location(location_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(location_id)
    |> File.ls!()
    |> Stream.map(&consolidate_year(&1, location_id, location_context, file))
    |> Stream.run()
  end

  defp consolidate_year(year, location_id, location_context, file) do
    @temporary_dir
    |> Path.join(location_context)
    |> Path.join(location_id)
    |> Path.join(year)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(nil, &add_each/2)
    |> write_to_file(location_context, location_id, year, file)
  end

  defp add_each(fields_1, nil) do
    Enum.map(fields_1, &String.to_integer/1)
  end

  defp add_each(fields_1, fields_2) do
    fields_1
    |> Enum.zip(fields_2)
    |> Enum.map(fn {field_1, field_2} -> String.to_integer(field_1) + field_2 end)
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
