defmodule HealthBoard.Scripts.Morbidities.VaccinesCoverages.Parser do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @output_file_path Path.join(@output_dir, "yearly_vaccines_coverages.csv")

  @columns %{
    bcg: %{column: "BCG", index: 0},
    double_adult_triple_acellular_pregnant: %{column: "Dupla adulto e tríplice acelular gestante", index: 1},
    dtp_ref_4_6_years: %{column: "DTP REF (4 e 6 anos)", index: 2},
    dtp: %{column: "DTP", index: 3},
    dtpa_pregnant: %{column: "dTpa gestante", index: 4},
    haemophilus_influenzae_b: %{column: "Haemophilus influenzae b", index: 5},
    hepatitis_a: %{column: "Hepatite A", index: 6},
    hepatitis_b_at_most_30_days_children: %{column: "Hepatite B  em crianças até 30 dias", index: 7},
    hepatitis_b: %{column: "Hepatite B", index: 8},
    human_rotavirus: %{column: "Rotavírus Humano", index: 9},
    measles: %{column: "Sarampo", index: 10},
    meningococcus_c_1st_reference: %{column: "Meningococo C (1º ref)", index: 11},
    meningococcus_c: %{column: "Meningococo C", index: 12},
    pentavalent: %{column: "Penta", index: 13},
    pneumococcal_1st_reference: %{column: "Pneumocócica(1º ref)", index: 14},
    pneumococcal: %{column: "Pneumocócica", index: 15},
    polio_1st_reference: %{column: "Poliomielite(1º ref)", index: 16},
    polio_4_years: %{column: "Poliomielite 4 anos", index: 17},
    polio: %{column: "Poliomielite", index: 18},
    tetra_viral: %{column: "Tetra Viral(SRC+VZ)", index: 19},
    tetravalent: %{column: "Tetravalente (DTP/Hib) (TETRA)", index: 20},
    triple_bacterial: %{column: "Tríplice Bacteriana(DTP)(1º ref)", index: 21},
    triple_viral_d1: %{column: "Tríplice Viral  D1", index: 22},
    triple_viral_d2: %{column: "Tríplice Viral  D2", index: 23},
    yellow_fever: %{column: "Febre Amarela", index: 24}
  }

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_file_path)
    File.mkdir_p!(@output_dir)

    cities = get_cities()

    @input_dir
    |> File.ls!()
    |> Task.async_stream(&parse_and_append(&1, cities), timeout: :infinity)
    |> Stream.run()

    sort_file()

    :ok
  end

  defp get_cities do
    for %{id: id} <- Locations.list_by(level: Locations.city_level()), into: %{} do
      {"#{div(id, 10)}", id}
    end
  end

  defp parse_and_append(file_name, cities) do
    year = get_year_from_file_name(file_name)

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> fetch_indexes_parse_and_append(cities, year)
  end

  defp get_year_from_file_name(file_name) do
    file_name
    |> String.slice(5, 2)
    |> String.to_integer()
    |> Kernel.+(2000)
  end

  defp fetch_indexes_parse_and_append(stream, cities, year) do
    [first_line] = Enum.to_list(Stream.take(stream, 1))
    columns = Enum.map(@columns, &fetch_source_index(&1, first_line))

    stream
    |> Stream.drop(1)
    |> Task.async_stream(&do_parse_and_append(&1, cities, year, columns), timeout: :infinity)
    |> Stream.run()
  end

  defp fetch_source_index({_column_id, %{column: column_name} = column}, first_line) do
    case Enum.find_index(first_line, &(&1 == column_name)) do
      nil -> column
      index -> Map.put(column, :source_index, index)
    end
  end

  defp do_parse_and_append([location_cell | coverages_cells], cities, year, columns) do
    location_id = fetch_location_id(cities, location_cell)
    coverages = Enum.map(columns, &fetch_coverage(&1, coverages_cells))

    unless is_nil(location_id) do
      append(location_id, year, coverages)
    end
  end

  defp fetch_location_id(_cities, "Total") do
    nil
  end

  defp fetch_location_id(cities, location_cell) do
    [location_id, _location_cell] = String.split(location_cell, " ", parts: 2)

    if String.length(location_id) == 6 do
      Map.fetch!(cities, location_id)
    else
      location_id
    end
  rescue
    _error ->
      Logger.warn(~s(Location "#{location_cell}" not found))
      nil
  end

  defp fetch_coverage(%{source_index: index}, coverages_cells) do
    coverages_cells
    |> Enum.at(index, "0,0")
    |> String.replace(",", ".")
  end

  defp fetch_coverage(_columns, _coverages_cells), do: "0.0"

  defp append(location_id, year, coverages) do
    line = [location_id, year] ++ coverages
    File.write!(@output_file_path, Enum.join(line, ",") <> "\n", [:append])
  end

  defp sort_file do
    Logger.info("Sorting file #{@output_file_path}")

    {_result, 0} = System.cmd("sort", ~w[-o #{@output_file_path} #{@output_file_path}])
  end
end
