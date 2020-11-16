defmodule HealthBoard.Scripts.DATASUS.Immediates.CholeraConsolidator do
  require Logger
  alias HealthBoard.Contexts.Geo

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @source_path Path.join(@dir, "sources/registries/cholera.csv")
  @results_dir Path.join(@dir, "immediates/cholera")
  @results_daily_resident_dir Path.join(@results_dir, "daily/resident")
  @results_daily_source_dir Path.join(@results_dir, "daily/source")
  @results_yearly_resident_dir Path.join(@results_dir, "yearly/resident")
  @results_yearly_source_dir Path.join(@results_dir, "yearly/source")
  @groups {%{}, %{}, %{}, %{}}

  @columns [
    :cases,
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
    :ignored_age_group,
    :male,
    :female,
    :ignored_sex,
    :confirmed,
    :discarded,
    :ignored_classification,
    :healed,
    :died_from_disease,
    :died_from_other_causes,
    :ignored_evolution,
    :type_unclean_water,
    :type_sewer_exposure,
    :type_food,
    :type_displacement,
    :other_type,
    :ignored_type
  ]

  @spec run :: :ok
  def run do
    File.rm_rf!(@results_dir)
    File.mkdir_p!(@results_daily_resident_dir)
    File.mkdir_p!(@results_daily_source_dir)
    File.mkdir_p!(@results_yearly_resident_dir)
    File.mkdir_p!(@results_yearly_source_dir)

    cities = Geo.Cities.list()

    @source_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Stream.with_index(1)
    |> Enum.reduce(@groups, &group_data(&1, &2, cities))
    |> write_csvs("cities")
    |> consolidate_per_health_region()
    |> write_csvs("health_regions")
    |> consolidate_per_state()
    |> write_csvs("states")
    |> consolidate_per_region()
    |> write_csvs("regions")
    |> consolidate_country()
    |> write_csvs("countries")
  end

  defp group_data({line, line_index}, groups, cities) do
    if rem(line_index, 100_000) == 0 do
      Logger.info("Parsing line #{line_index}")
    end

    line
    |> parse_line(cities)
    |> merge_to_groups(groups)
  end

  defp parse_line([date, source_city_id, resident_city_id, age_code, sex, classification, evolution, type], cities) do
    date = Date.from_iso8601!(date)
    {year, week} = :calendar.iso_week_number({date.year, date.month, date.day})

    resident_city = find_city(cities, resident_city_id)
    source_city = find_city(cities, source_city_id)

    fields = [
      :cases,
      identify_age_group(age_code),
      identify_sex(sex),
      identify_classification(classification),
      identify_evolution(evolution),
      identify_type(type)
    ]

    {
      source_city,
      resident_city,
      date,
      year,
      week,
      fields
    }
  end

  defp find_city(cities, city_id) do
    city_id = if String.starts_with?(city_id, "53"), do: "530010", else: city_id

    case Enum.find(cities, &(div(&1.id, 10) == String.to_integer(city_id))) do
      nil ->
        Logger.warn("City with id #{city_id} not found")
        nil

      city ->
        city
    end
  end

  defp identify_age_group(age_code) do
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

  defp identify_sex(sex) do
    case sex do
      "M" -> :male
      "F" -> :female
      _sex -> :ignored_sex
    end
  end

  defp identify_classification(classification) do
    case classification do
      "1" -> :confirmed
      "2" -> :discarded
      _classification -> :ignored_classification
    end
  end

  defp identify_evolution(evolution) do
    case evolution do
      "1" -> :healed
      "2" -> :died_from_disease
      "3" -> :died_from_other_causes
      _evolution -> :ignored_evolution
    end
  end

  defp identify_type(type) do
    case type do
      "1" -> :type_unclean_water
      "2" -> :type_sewer_exposure
      "3" -> :type_food
      "4" -> :type_displacement
      "5" -> :other_type
      _type -> :ignored_type
    end
  end

  defp merge_to_groups(data, groups) do
    {source_city, resident_city, date, year, week, fields} = data
    {daily_resident_group, daily_source_group, yearly_resident_group, yearly_source_group} = groups

    {
      merge_to_group(daily_resident_group, resident_city, {date, week}, fields),
      merge_to_group(daily_source_group, source_city, {date, week}, fields),
      merge_to_group(yearly_resident_group, resident_city, year, fields),
      merge_to_group(yearly_source_group, source_city, year, fields)
    }
  end

  defp merge_to_group(group, city, date_fields, fields) do
    if city != nil do
      city_map = convert_to_city_map(city, date_fields, fields)

      if Enum.any?(group) do
        Map.merge(group, city_map, &merge_group_map/3)
      else
        city_map
      end
    else
      group
    end
  end

  defp convert_to_city_map(%{id: city_id, health_region_id: health_region_id}, date_fields, fields) do
    if is_tuple(date_fields) do
      {date, week} = date_fields
      date_data = Map.put(convert_fields_to_map(fields), :week, week)
      %{city_id => %{:health_region_id => health_region_id, date => date_data}}
    else
      year = date_fields
      %{city_id => %{:health_region_id => health_region_id, year => convert_fields_to_map(fields)}}
    end
  end

  defp convert_fields_to_map(fields) do
    for field <- fields, into: %{} do
      {field, 1}
    end
  end

  defp merge_group_map(_key, value1, value2) do
    Map.merge(value1, value2, &merge_geo_map/3)
  end

  defp merge_geo_map(key, value1, value2) do
    if key == :health_region_id do
      value1
    else
      Map.merge(value1, value2, &merge_date_map/3)
    end
  end

  defp merge_date_map(key, value1, value2) do
    if key == :week do
      value1
    else
      value1 + value2
    end
  end

  defp write_csvs({drg, dsg, yrg, ysg} = groups, context) do
    write_csv(drg, Path.join(@results_daily_resident_dir, context))
    write_csv(dsg, Path.join(@results_daily_source_dir, context))
    write_csv(yrg, Path.join(@results_yearly_resident_dir, context))
    write_csv(ysg, Path.join(@results_yearly_source_dir, context))
    groups
  end

  defp write_csv(group, dir_path) do
    File.mkdir_p!(dir_path)
    Enum.each(group, &write_geo_csvs(&1, dir_path))
  end

  defp write_geo_csvs({geo_id, dates_data}, dir_path) do
    file = File.open!(Path.join(dir_path, "#{geo_id}.csv"), [:write])

    dates_data
    |> Map.drop([:health_region_id])
    |> Enum.each(&write_date_data(&1, file))

    File.close(file)
  end

  defp write_date_data({date_or_year, data}, file) do
    line =
      case {Map.pop(data, :week), date_or_year} do
        {{nil, data}, year} -> "#{year},#{join_data(data)}\n"
        {{week, data}, date} -> "#{date},#{week},#{join_data(data)}\n"
      end

    IO.write(file, line)
  end

  defp join_data(data) do
    @columns
    |> Enum.map(&Map.get(data, &1, 0))
    |> Enum.join(",")
  end

  defp consolidate_per_health_region({drg, dsg, yrg, ysg}) do
    {
      Enum.reduce(drg, %{}, &merge_from_health_region/2),
      Enum.reduce(dsg, %{}, &merge_from_health_region/2),
      Enum.reduce(yrg, %{}, &merge_from_health_region/2),
      Enum.reduce(ysg, %{}, &merge_from_health_region/2)
    }
  end

  defp merge_from_health_region({_city_id, dates_data}, group_data) do
    {health_region_id, dates_data} = Map.pop!(dates_data, :health_region_id)
    Map.merge(group_data, %{health_region_id => dates_data}, &merge_group_map/3)
  end

  defp consolidate_per_state({drg, dsg, yrg, ysg}) do
    {
      Enum.reduce(drg, %{}, &merge_from_state/2),
      Enum.reduce(dsg, %{}, &merge_from_state/2),
      Enum.reduce(yrg, %{}, &merge_from_state/2),
      Enum.reduce(ysg, %{}, &merge_from_state/2)
    }
  end

  defp merge_from_state({health_region_id, dates_data}, group_data) do
    state_id = div(health_region_id, 1_000)
    Map.merge(group_data, %{state_id => dates_data}, &merge_group_map/3)
  end

  defp consolidate_per_region({drg, dsg, yrg, ysg}) do
    {
      Enum.reduce(drg, %{}, &merge_from_region/2),
      Enum.reduce(dsg, %{}, &merge_from_region/2),
      Enum.reduce(yrg, %{}, &merge_from_region/2),
      Enum.reduce(ysg, %{}, &merge_from_region/2)
    }
  end

  defp merge_from_region({state_id, dates_data}, group_data) do
    region_id = div(state_id, 10)
    Map.merge(group_data, %{region_id => dates_data}, &merge_group_map/3)
  end

  defp consolidate_country({drg, dsg, yrg, ysg}) do
    {
      Enum.reduce(drg, %{}, &merge_from_country/2),
      Enum.reduce(dsg, %{}, &merge_from_country/2),
      Enum.reduce(yrg, %{}, &merge_from_country/2),
      Enum.reduce(ysg, %{}, &merge_from_country/2)
    }
  end

  defp merge_from_country({_region_id, dates_data}, group_data) do
    Map.merge(group_data, %{76 => dates_data}, &merge_group_map/3)
  end
end

HealthBoard.Scripts.DATASUS.Immediates.CholeraConsolidator.run()
