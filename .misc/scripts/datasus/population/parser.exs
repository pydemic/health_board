defmodule HealthBoard.Scripts.DATASUSPopulation.Parser do
  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @sources_dir Path.join(@dir, "sources/datasus_population")
  @results_dir Path.join(@dir, "results/demographic")
  @years 2000..2020
  @types [:age, :sex]

  @age_fields [
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
    :age_80_or_more
  ]

  @sex_fields [:male, :female]

  @groups %{cities: %{}, health_regions: %{}, states: %{}, regions: %{}, countries: %{}}

  @headers Enum.join([:geo_id, :year] ++ @sex_fields ++ @age_fields, ",")

  alias HealthBoard.Contexts.Geo

  @spec parse :: :ok
  def parse do
    cities = Geo.Cities.list()

    for year <- @years, type <- @types do
      @sources_dir
      |> Path.join("#{year}_#{type}.csv")
      |> File.stream!()
      |> NimbleCSV.RFC4180.parse_stream()
      |> Stream.map(&([type, year] ++ &1))
      |> Enum.to_list()
    end
    |> Enum.reduce([], &(&1 ++ &2))
    |> Enum.reduce(@groups, &group(&1, &2, cities))
    |> generate_csvs()
  end

  defp group([type, year, city_data | data], groups, cities) do
    city = parse_city(city_data, cities)
    attrs = get_attrs(groups.cities, city.id, year, data, get_fields(type))
    update_groups(groups, city, year, attrs)
  end

  defp parse_city(city_data, cities) do
    [old_city_id, _name] = String.split(city_data, " ", parts: 2)
    Enum.find(cities, &(old_city_id == Integer.to_string(div(&1.id, 10))))
  end

  defp get_fields(type) do
    case type do
      :age -> @age_fields
      :sex -> @sex_fields
    end
  end

  defp get_attrs(cities_population, city_id, year, data, fields) do
    cities_population
    |> Map.get(year, %{})
    |> Map.get(city_id, %{})
    |> Map.merge(parse_data(fields, data))
  end

  defp parse_data(fields, data) do
    fields
    |> Enum.zip(Enum.map(data, &String.to_integer/1))
    |> Map.new()
  end

  defp update_groups(groups, city, year, attrs) do
    groups
    |> Map.update!(:cities, &update_group(&1, city.id, year, attrs, false))
    |> Map.update!(:health_regions, &update_group(&1, city.health_region_id, year, attrs))
    |> Map.update!(:states, &update_group(&1, city.state_id, year, attrs))
    |> Map.update!(:regions, &update_group(&1, city.region_id, year, attrs))
    |> Map.update!(:countries, &update_group(&1, city.country_id, year, attrs))
  end

  defp update_group(group, id, year, attrs, add? \\ true) do
    if add? do
      Map.update(group, id, Map.new([{year, attrs}]), &add_attrs(&1, year, attrs))
    else
      Map.update(group, id, Map.new([{year, attrs}]), &merge_attrs(&1, year, attrs))
    end
  end

  defp add_attrs(years_population, year, attrs) do
    Map.update(years_population, year, attrs, &do_add_attrs(&1, attrs))
  end

  defp merge_attrs(years_population, year, attrs) do
    Map.update(years_population, year, attrs, &Map.merge(&1, attrs))
  end

  defp do_add_attrs(attrs1, attrs2) do
    attrs =
      for key <- @sex_fields ++ @age_fields, into: %{} do
        {key, Map.get(attrs1, key, 0) + Map.get(attrs2, key, 0)}
      end

    Map.merge(attrs1, Map.new(attrs))
  end

  defp generate_csvs(groups) do
    Enum.each(groups, &generate_csv/1)
  end

  defp generate_csv({key, group}) do
    data =
      group
      |> Enum.map(&generate_lines/1)
      |> Enum.sort()
      |> Enum.join("\n")

    @results_dir
    |> Path.join("#{key}_population.csv")
    |> File.write!(@headers <> "\n" <> data)
  end

  defp generate_lines({id, yearly_attrs}) do
    yearly_attrs
    |> Enum.map(&generate_line(id, &1))
    |> Enum.sort()
    |> Enum.join("\n")
  end

  defp generate_line(id, {year, attrs}) do
    line = [id, year] ++ Enum.map(@sex_fields ++ @age_fields, &Map.get(attrs, &1))
    Enum.join(line, ",")
  end
end

HealthBoard.Scripts.DATASUSPopulation.Parser.parse()
