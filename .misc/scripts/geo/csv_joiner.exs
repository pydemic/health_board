defmodule HealthBoard.Scripts.Geo.CSVJoiner do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @locations ~w[countries regions states health_regions cities]a

  @spec run :: :ok
  def run do
    File.cd!(@dir)
    File.rm_rf!("locations.csv")
    Enum.map(@locations, &add/1)
    sort_result_file()
    zip_result_file()
    File.rm_rf!("locations.csv")
  end

  defp add(location) do
    Logger.info("Joining #{location}")

    csv_file_name = "#{location}.csv"

    parse_function =
      case location do
        :countries -> &parse_country_line/1
        :regions -> &parse_region_line/1
        :states -> &parse_state_line/1
        :health_regions -> &parse_health_region_line/1
        :cities -> &parse_city_line/1
      end

    "sources"
    |> Path.join(csv_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(parse_function)
    |> Stream.reject(&is_nil/1)
    |> NimbleCSV.RFC4180.dump_to_stream()
    |> Stream.into(File.stream!("locations.csv", [:append, :utf8]))
    |> Stream.run()
  end

  defp parse_country_line([id, name, abbr, _, _]) do
    [0, nil, String.to_integer(id), name, abbr]
  end

  defp parse_region_line([parent_id, id, name, abbr, _, _]) do
    [1, String.to_integer(parent_id), String.to_integer(id), name, abbr]
  end

  defp parse_state_line([_, parent_id, id, name, abbr, _, _]) do
    [2, String.to_integer(parent_id), String.to_integer(id), name, abbr]
  end

  defp parse_health_region_line([_, _, parent_id, id, name, _, _]) do
    [3, String.to_integer(parent_id), String.to_integer(id), name, nil]
  end

  defp parse_city_line([_, _, _, parent_id, id, name, _, _]) do
    [4, String.to_integer(parent_id), String.to_integer(id), name, nil]
  end

  defp sort_result_file do
    Logger.info("Sorting file")

    {_result, 0} = System.cmd("sort", ~w[-o locations.csv locations.csv])
  end

  defp zip_result_file do
    Logger.info("Zipping file")

    {_result, 0} = System.cmd("zip", ~w[-r locations.zip locations.csv])
  end
end

HealthBoard.Scripts.Geo.CSVJoiner.run()
