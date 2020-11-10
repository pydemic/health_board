defmodule HealthBoard.Scripts.GeoJSON.HealthRegionsFromStates do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @geojson Path.join(@dir, "health_regions.geojson")
  @states_ids [
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    31,
    32,
    33,
    34,
    35,
    41,
    42,
    43,
    50,
    51,
    52,
    53
  ]

  @spec run :: :ok
  def run do
    features =
      @geojson
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("features")

    Enum.reduce(@states_ids, features, &extract_health_regions_from_state/2)
  end

  def extract_health_regions_from_state(state_id, features) do
    {features, health_regions_geojson} = do_extract_health_regions_from_state(state_id, features)

    file_path = Path.join(@dir, "#{state_id}/health_regions.geojson")

    health_regions_geojson
    |> Jason.encode!()
    |> write_geojson(file_path)

    features
  end

  defp do_extract_health_regions_from_state(state_id, features) do
    {health_region_features, features} = Enum.split_with(features, &filter_feature(&1, state_id))
    {features, %{"type" => "FeatureCollection", "features" => Enum.map(health_region_features, &sanitize_feature/1)}}
  end

  defp filter_feature(%{"properties" => %{"regiao_saude_health_region_id" => health_region_id}}, state_id) do
    div(health_region_id, 1_000) == state_id
  end

  defp sanitize_feature(%{"geometry" => geometry, "properties" => properties}) do
    %{"regiao_saude_health_region_id" => health_region_id} = properties
    %{"geometry" => geometry, "id" => health_region_id}
  end

  defp write_geojson(geojson, file_path) do
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, geojson)
  end
end

HealthBoard.Scripts.GeoJSON.HealthRegionsFromStates.run()
