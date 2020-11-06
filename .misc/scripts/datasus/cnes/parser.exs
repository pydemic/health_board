defmodule HealthBoard.Scripts.DATASUSCNES.Parser do
  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/datasus_cnes")
  @source_csv_path Path.join(@sources_dir, "tbEstabelecimento202009.csv")

  @results_dir Path.join(@dir, "results/logistics")
  @result_csv_path Path.join(@results_dir, "health_institutions.csv")

  @headers "city_id,id,name"
  @columns [{31, :city_id}, {1, :integer}, {6, :string}]

  @brasilia_id 5_300_108

  alias HealthBoard.Contexts.Geo

  @spec parse :: :ok
  def parse do
    cities = Geo.Cities.list()

    @source_csv_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(&extract_data(&1, cities))
    |> Enum.to_list()
    |> generate_csv()
  end

  defp extract_data(data, cities) do
    Enum.map(@columns, &extract_cell(&1, data, cities))
  end

  defp extract_cell({index, type}, data, cities) do
    case {type, Enum.at(data, index)} do
      {:city_id, value} -> parse_city_id(value, cities)
      {:integer, value} -> String.to_integer(value)
      {:string, value} -> value
    end
  end

  defp parse_city_id(value, cities) do
    if String.starts_with?(value, "53") do
      @brasilia_id
    else
      Enum.find(cities, &(value == Integer.to_string(div(&1.id, 10)))).id
    end
  end

  defp generate_csv(data) do
    data =
      data
      |> Enum.map(&Enum.join(&1, ","))
      |> Enum.sort()
      |> Enum.join("\n")

    File.write!(@result_csv_path, @headers <> "\n" <> data)
  end
end

HealthBoard.Scripts.DATASUSCNES.Parser.parse()
