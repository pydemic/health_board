defmodule HealthBoard.Scripts.DATASUS.SINASC.CSVJoiner do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @locations Enum.with_index(~w[countries regions states health_regions cities]a)

  @correlations [
    daily: [
      resident: @locations,
      source: @locations ++ [{:health_institutions, 5}]
    ],
    yearly: [
      resident: @locations,
      source: @locations ++ [{:health_institutions, 5}]
    ]
  ]

  @result_file_name "locations_births"

  @spec run :: :ok
  def run do
    File.cd!(@dir)
    File.rm_rf!("#{@result_file_name}.csv")
    Enum.each(@correlations, &add/1)
    sort_result_file()
    zip_result_file()
    File.rm_rf!("#{@result_file_name}.csv")
  end

  defp add({consolidation_type, correlations}) do
    Enum.each(correlations, &add(consolidation_type, &1))
  end

  defp add(consolidation_type, {location_context, correlations}) do
    Enum.each(correlations, &add(consolidation_type, location_context, &1))
  end

  defp add(consolidation_type, location_context, {location, location_level}) do
    Logger.info("Joining #{consolidation_type} #{location_context} #{location} births")

    temporary_dir = String.to_charlist("/tmp/#{:os.system_time(:millisecond)}")

    try do
      "sources"
      |> Path.join(get_zip_relative_path(consolidation_type, location_context, location))
      |> String.to_charlist()
      |> :zip.unzip(cwd: temporary_dir)
      |> elem(1)
      |> Task.async_stream(&do_add(consolidation_type, location_context, location_level, &1))
      |> Stream.run()

      File.rm_rf!(temporary_dir)
    rescue
      error ->
        File.rm_rf!(temporary_dir)
        reraise(error, __STACKTRACE__)
    end

    :ok
  end

  defp do_add(consolidation_type, location_context, location_level, csv_path) do
    location_id =
      csv_path
      |> Path.basename(".csv")
      |> String.to_integer()

    csv_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(&parse_line(&1, consolidation_type, location_context, location_level, location_id))
    |> NimbleCSV.RFC4180.dump_to_stream()
    |> Stream.into(File.stream!("#{@result_file_name}.csv", [:append, :utf8]))
    |> Stream.run()
  end

  defp get_zip_relative_path(consolidation_type, location_context, location) do
    case consolidation_type do
      :daily -> "daily/#{location_context}/#{location_context}_#{location}_births.zip"
      :yearly -> "yearly/#{location_context}/yearly_#{location_context}_#{location}_births.zip"
    end
  end

  defp parse_line(line, :daily, location_context, location_level, location_id) do
    [date | line] = line
    line = Enum.map(line, &String.to_integer/1)
    location_context = location_context_index(location_context)

    [0, location_context, location_level, location_id, date] ++ line
  end

  defp parse_line(line, :yearly, location_context, location_level, location_id) do
    line = Enum.map(line, &String.to_integer/1)
    [year | _line] = line
    location_context = location_context_index(location_context)

    [1, location_context, location_level, location_id, nil, year, nil] ++ line
  end

  defp location_context_index(location_context) do
    case location_context do
      :resident -> 0
      :source -> 1
    end
  end

  defp sort_result_file do
    Logger.info("Sorting file")

    {_result, 0} = System.cmd("sort", ~w[-o #{@result_file_name}.csv #{@result_file_name}.csv])
  end

  defp zip_result_file do
    Logger.info("Zipping file")

    {_result, 0} = System.cmd("zip", ~w[-r #{@result_file_name}.zip #{@result_file_name}.csv])
  end
end

HealthBoard.Scripts.DATASUS.SINASC.CSVJoiner.run()
