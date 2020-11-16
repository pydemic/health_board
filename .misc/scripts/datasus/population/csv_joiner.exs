defmodule HealthBoard.Scripts.DATASUS.Population.CSVJoiner do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @locations ~w[countries regions states health_regions cities]a

  @result_file_name "yearly_locations_populations"

  @spec run :: :ok
  def run do
    File.cd!(@dir)
    File.rm_rf!("#{@result_file_name}.csv")
    Enum.map(@locations, &add/1)
    sort_result_file()
    zip_result_file()
    File.rm_rf!("#{@result_file_name}.csv")
  end

  defp add(location) do
    Logger.info("Joining #{location}_population")

    csv_file_name = "#{location}_population.csv"

    "sources"
    |> Path.join(csv_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(&parse_line/1)
    |> Stream.reject(&is_nil/1)
    |> NimbleCSV.RFC4180.dump_to_stream()
    |> Stream.into(File.stream!("#{@result_file_name}.csv", [:append, :utf8]))
    |> Stream.run()
  end

  defp parse_line(line) do
    Enum.map(line, &String.to_integer/1)
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

HealthBoard.Scripts.DATASUS.Population.CSVJoiner.run()
