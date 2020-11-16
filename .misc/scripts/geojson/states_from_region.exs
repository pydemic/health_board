defmodule HealthBoard.Scripts.GeoJSON.StatesFromRegion do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @geojson Path.join(@dir, "source/states.geojson")
  @region_id "5"
  @region_geojson Path.join(@dir, "#{@region_id}/states.geojson")

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
    %{"type" => "FeatureCollection", "features" => filter_features(features)}
  end

  defp filter_features(features) do
    features
    |> Enum.filter(&filter_feature/1)
    |> Enum.map(&sanitize_feature/1)
  end

  defp filter_feature(%{"properties" => %{"CD_GEOCUF" => state_id}}) do
    String.first(state_id) == @region_id
  end

  defp sanitize_feature(%{"geometry" => geometry, "properties" => %{"CD_GEOCUF" => state_id}}) do
    %{"geometry" => geometry, "type" => "Feature", "id" => String.to_integer(state_id)}
  end

  defp write_geojson(geojson) do
    File.mkdir_p!(Path.dirname(@region_geojson))
    File.write!(@region_geojson, geojson)
  end
end

HealthBoard.Scripts.GeoJSON.StatesFromRegion.run()
