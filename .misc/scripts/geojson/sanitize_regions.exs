defmodule HealthBoard.Scripts.GeoJSON.StatesFromRegion do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @geojson Path.join(@dir, "source/regions.geojson")
  @region_geojson Path.join(@dir, "regions.geojson")

  @spec run :: :ok
  def run do
    @geojson
    |> File.read!()
    |> Jason.decode!()
    |> extract_states_from_region()
    |> Jason.encode!()
    |> write_geojson()
  end

  defp extract_states_from_region(%{"features" => features}) do
    %{"type" => "FeatureCollection", "features" => Enum.map(features, &sanitize_feature/1)}
  end

  defp sanitize_feature(%{"geometry" => geometry, "id" => id}) do
    %{"geometry" => geometry, "type" => "Feature", "id" => parse_region_id(id)}
  end

  defp parse_region_id(id) do
    case id do
      1 -> 5
      2 -> 2
      3 -> 1
      4 -> 3
      5 -> 4
    end
  end

  defp write_geojson(geojson) do
    File.write!(@region_geojson, geojson)
  end
end

HealthBoard.Scripts.GeoJSON.StatesFromRegion.run()
