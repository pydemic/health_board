defmodule HealthBoard.Scripts.DATASUS.SINASC.CSVFilter do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @result_file_name "yearly_locations_births"

  @spec run :: :ok
  def run do
    File.cd!(@dir)
    File.rm_rf!("#{@result_file_name}.csv")

    "locations_births.csv"
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.reject(&(Enum.at(&1, 0) == "0" or Enum.at(&1, 2) == "5"))
    |> Stream.map(fn [_consolidation_type | line] -> line end)
    |> NimbleCSV.RFC4180.dump_to_stream()
    |> Stream.into(File.stream!("#{@result_file_name}.csv", [:write, :utf8]))
    |> Stream.run()
  end
end

HealthBoard.Scripts.DATASUS.SINASC.CSVFilter.run()
