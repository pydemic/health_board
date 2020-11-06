defmodule HealthBoard.Scripts.DATASUS.SINASC.BaseDataParser do
  require Logger
  alias HealthBoard.Contexts.Geo

  @timeout :infinity

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")
  @base_data_dir Path.join(@sources_dir, "base_data")

  @contexts ["DN", "DNP"]

  @source_columns [
    "DTNASC",
    "CODESTAB",
    "CODMUNNASC",
    "CODMUNRES",
    "IDADEMAE",
    "SEXO",
    "PARTO",
    "LOCNASC",
    "GESTACAO",
    "PESO",
    "CONSULTAS"
  ]

  @fields [
    :source_city_id,
    :source_health_institution_id,
    :resident_city_id,
    :date,
    :year,
    :week,
    :births,
    :mother_age_10_or_less,
    :mother_age_10_14,
    :mother_age_15_19,
    :mother_age_20_24,
    :mother_age_25_29,
    :mother_age_30_34,
    :mother_age_35_39,
    :mother_age_40_44,
    :mother_age_45_49,
    :mother_age_50_54,
    :mother_age_55_59,
    :mother_age_60_or_more,
    :ignored_mother_age,
    :child_male_sex,
    :child_female_sex,
    :ignored_child_sex,
    :vaginal_delivery,
    :cesarean_delivery,
    :other_delivery,
    :ignored_delivery,
    :birth_at_hospital,
    :birth_at_other_health_institution,
    :birth_at_home,
    :birth_at_other_location,
    :ignored_birth_location,
    :gestation_duration_21_or_less,
    :gestation_duration_22_27,
    :gestation_duration_28_31,
    :gestation_duration_32_36,
    :gestation_duration_37_41,
    :gestation_duration_42_or_more,
    :ignored_gestation_duration,
    :child_mass_500_or_less,
    :child_mass_500_999,
    :child_mass_1000_1499,
    :child_mass_1500_2499,
    :child_mass_2500_2999,
    :child_mass_3000_3999,
    :child_mass_4000_or_more,
    :ignored_child_mass,
    :prenatal_consultations_none,
    :prenatal_consultations_1_3,
    :prenatal_consultations_4_6,
    :prenatal_consultations_7_or_more,
    :ignored_prenatal_consultations
  ]

  @headers Enum.join(@fields, ",")
  @default_attrs for field <- @fields, into: %{}, do: {field, nil}

  @spec parse :: :ok
  def parse do
    cities = Geo.Cities.list()

    Logger.info("#{Enum.count(cities)} cities fetched")

    @contexts
    |> Task.async_stream(&create_base_data(&1, cities), timeout: @timeout)
    |> Stream.run()
  end

  defp create_base_data(context, cities) do
    @sources_dir
    |> Path.join(context)
    |> File.ls!()
    |> inform_files(context)
    |> Enum.with_index(1)
    |> Task.async_stream(&extract_csv(&1, context, cities), timeout: @timeout)
    |> Stream.run()
  end

  defp inform_files(files, context) do
    Logger.info("#{Enum.count(files)} files from context #{context} identified")
    files
  end

  defp extract_csv({source_file_name, index}, context, cities) do
    code = "#{context} #{index}"
    Logger.info("[#{code}] Extracting #{source_file_name}")

    source_file_path =
      @sources_dir
      |> Path.join(context)
      |> Path.join(source_file_name)

    source_indexes = get_source_indexes(source_file_path)

    base_data_file =
      @base_data_dir
      |> Path.join(source_file_name)
      |> File.open!([:append])

    IO.write(base_data_file, @headers <> "\n")

    source_file_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.with_index(1)
    |> Task.async_stream(&write_base_data(&1, source_indexes, base_data_file, cities, code), timeout: @timeout)
    |> Stream.run()

    File.close(base_data_file)

    Logger.info("[#{context} #{index}] #{source_file_name} extracted")
  end

  defp get_source_indexes(source_file_path) do
    source_file = File.open!(source_file_path, [:read])

    source_headers =
      source_file
      |> IO.read(:line)
      |> String.replace("\"", "")
      |> String.split(",")

    File.close(source_file)

    Enum.map(@source_columns, &find_index(&1, source_headers))
  end

  defp find_index(column_name, data) do
    Enum.find_index(data, &(&1 == column_name))
  end

  defp write_base_data({data, index}, source_indexes, base_data_file, cities, code) do
    if rem(index, 25_000) == 0 do
      Logger.info("    [#{code}] #{index} lines parsed")
    end

    base_data =
      source_indexes
      |> Enum.map(&find_data(&1, data))
      |> generate_base_data(cities)

    line =
      @fields
      |> Enum.map(&Map.get(base_data, &1))
      |> Enum.join(",")

    IO.write(base_data_file, line <> "\n")
  rescue
    error ->
      Logger.error("Failed to parse data: #{inspect(data)}\n#{Expection.format(:error, error, __STACKTRACE__)}")
  end

  defp find_data(index, data) do
    if is_nil(index) do
      nil
    else
      Enum.at(data, index)
    end
  end

  defp generate_base_data(base_data, cities) do
    [
      date,
      source_health_institution_id,
      source_city_id,
      resident_city_id,
      mother_age,
      child_sex,
      delivery_type,
      location_type,
      gestation_duration_type,
      child_mass,
      prenatal_consultations
    ] = base_data

    @default_attrs
    |> Map.put(:births, 1)
    |> parse_source_health_institution_id(source_health_institution_id)
    |> parse_source_city_id(source_city_id, cities)
    |> parse_resident_city_id(resident_city_id, cities)
    |> parse_date!(date)
    |> parse_mother_age(mother_age)
    |> parse_child_sex(child_sex)
    |> parse_delivery_type(delivery_type)
    |> parse_location_type(location_type)
    |> parse_gestation_duration_type(gestation_duration_type)
    |> parse_child_mass(child_mass)
    |> parse_prenatal_consultations(prenatal_consultations)
  end

  defp parse_source_health_institution_id(attrs, source_health_institution_id) do
    Map.put(attrs, :source_health_institution_id, String.to_integer(source_health_institution_id))
  rescue
    _error -> attrs
  end

  defp parse_source_city_id(attrs, source_city_id, cities) do
    Map.put(attrs, :source_city_id, get_city_id(cities, source_city_id))
  end

  defp parse_resident_city_id(attrs, source_city_id, cities) do
    Map.put(attrs, :resident_city_id, get_city_id(cities, source_city_id))
  end

  defp get_city_id(cities, city_id) do
    id = String.to_integer(city_id)

    if String.length(city_id) == 6 do
      Enum.find(cities, &(id == div(&1.id, 10))).id
    else
      Enum.find(cities, &(id == &1.id)).id
    end
  rescue
    _error -> nil
  end

  defp parse_date!(attrs, date_string) do
    if String.length(date_string) == 8 do
      maybe_month = String.to_integer(String.slice(date_string, 4, 2))

      {year, month, day} =
        if maybe_month < 13 do
          {
            String.to_integer(String.slice(date_string, 0, 4)),
            String.to_integer(String.slice(date_string, 4, 2)),
            String.to_integer(String.slice(date_string, 6, 2))
          }
        else
          {
            String.to_integer(String.slice(date_string, 4, 4)),
            String.to_integer(String.slice(date_string, 2, 2)),
            String.to_integer(String.slice(date_string, 0, 2))
          }
        end

      {:ok, date} = Date.new(year, month, day)
      {_year, week} = :calendar.iso_week_number({year, month, day})

      Map.merge(attrs, %{date: date, year: year, week: week})
    else
      raise "Date string is not valid."
    end
  end

  defp parse_mother_age(attrs, age_string) do
    Map.put(attrs, get_mother_age_key(age_string), 1)
  end

  defp get_mother_age_key(age_string) do
    age = String.to_integer(age_string)

    cond do
      age <= 10 -> :mother_age_10_or_less
      age <= 14 -> :mother_age_10_14
      age <= 19 -> :mother_age_15_19
      age <= 24 -> :mother_age_20_24
      age <= 29 -> :mother_age_25_29
      age <= 34 -> :mother_age_30_34
      age <= 39 -> :mother_age_35_39
      age <= 44 -> :mother_age_40_44
      age <= 49 -> :mother_age_45_49
      age <= 54 -> :mother_age_50_54
      age <= 59 -> :mother_age_55_59
      true -> :mother_age_60_or_more
    end
  rescue
    _error -> :ignored_mother_age
  end

  defp parse_child_sex(attrs, sex_string) do
    Map.put(attrs, get_child_sex_key(sex_string), 1)
  end

  defp get_child_sex_key(sex_string) do
    case sex_string do
      "1" -> :child_male_sex
      "2" -> :child_female_sex
      _ -> :ignored_child_sex
    end
  end

  defp parse_delivery_type(attrs, delivery_type_string) do
    Map.put(attrs, get_delivery_key(delivery_type_string), 1)
  end

  defp get_delivery_key(delivery_type_string) do
    type = String.to_integer(delivery_type_string)

    cond do
      type == 1 -> :vaginal_delivery
      type == 2 -> :cesarean_delivery
      type > 2 and type < 9 -> :other_delivery
      true -> :ignored_delivery
    end
  rescue
    _error -> :ignored_delivery
  end

  defp parse_location_type(attrs, location_type_string) do
    Map.put(attrs, get_location_key(location_type_string), 1)
  end

  defp get_location_key(location_type_string) do
    type = String.to_integer(location_type_string)

    cond do
      type == 1 -> :birth_at_hospital
      type == 2 -> :birth_at_other_health_institution
      type == 3 -> :birth_at_home
      type == 4 -> :birth_at_other_location
      true -> :ignored_birth_location
    end
  rescue
    _error -> :ignored_birth_location
  end

  defp parse_gestation_duration_type(attrs, gestation_duration_type_string) do
    Map.put(attrs, get_gestation_duration_key(gestation_duration_type_string), 1)
  end

  defp get_gestation_duration_key(gestation_duration_type_string) do
    duration = String.to_integer(gestation_duration_type_string)

    cond do
      duration <= 21 -> :gestation_duration_21_or_less
      duration <= 27 -> :gestation_duration_22_27
      duration <= 31 -> :gestation_duration_28_31
      duration <= 36 -> :gestation_duration_32_36
      duration <= 41 -> :gestation_duration_37_41
      true -> :gestation_duration_42_or_more
    end
  rescue
    _error -> :ignored_gestation_duration
  end

  defp parse_child_mass(attrs, child_mass_string) do
    Map.put(attrs, get_child_mass_key(child_mass_string), 1)
  end

  defp get_child_mass_key(child_mass_string) do
    mass = String.to_integer(child_mass_string)

    cond do
      mass <= 500 -> :child_mass_500_or_less
      mass < 1000 -> :child_mass_500_999
      mass < 1500 -> :child_mass_1000_1499
      mass < 2500 -> :child_mass_1500_2499
      mass < 4000 -> :child_mass_3000_3999
      true -> :child_mass_4000_or_more
    end
  rescue
    _error -> :ignored_child_mass
  end

  defp parse_prenatal_consultations(attrs, prenatal_consultations_string) do
    Map.put(attrs, get_prenatal_consultations_key(prenatal_consultations_string), 1)
  end

  defp get_prenatal_consultations_key(prenatal_consultations_string) do
    consultations = String.to_integer(prenatal_consultations_string)

    cond do
      consultations == 0 -> :prenatal_consultations_none
      consultations <= 3 -> :prenatal_consultations_1_3
      consultations <= 6 -> :prenatal_consultations_4_6
      true -> :prenatal_consultations_7_or_more
    end
  rescue
    _error -> :ignored_prenatal_consultations
  end
end

HealthBoard.Scripts.DATASUS.SINASC.BaseDataParser.parse()
