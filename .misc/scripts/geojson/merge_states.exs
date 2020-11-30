defmodule HealthBoard.Scripts.GeoJSON.MergeStates do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")
  @output_file_path Path.join(@output_dir, "states.geojson")

  @spec run :: :ok
  def run do
    @input_dir
    |> File.ls!()
    |> Stream.flat_map(&extract_features_from_file/1)
    |> Enum.sort(&(&1["id"] <= &2["id"]))
    |> generate_geojson()
    |> write_geojson()
  end

  defp extract_features_from_file(file_name) do
    @input_dir
    |> Path.join(file_name)
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("features")
  end

  defp generate_geojson(features) do
    Jason.encode!(%{"type" => "FeatureCollection", "features" => features})
  end

  defp write_geojson(geojson) do
    File.mkdir_p!(@output_dir)
    File.write!(@output_file_path, geojson)
  end
end

HealthBoard.Scripts.GeoJSON.MergeStates.run()
