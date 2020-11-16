defmodule HealthBoard.Scripts.GeoJSON.CitiesFromHealthRegions do
  require Logger
  alias HealthBoard.Contexts.Geo.HealthRegions

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @geojson Path.join(@dir, "source/cities.geojson")

  @spec run :: :ok
  def run do
    health_regions = Enum.map(HealthRegions.list_by([]), &{&1.cities, &1.id, &1.state_id, &1.region_id, &1.country_id})

    features =
      @geojson
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("features")

    Enum.reduce(health_regions, features, &extract_cities_from_health_region/2)
  end

  def extract_cities_from_health_region({cities, health_region_id, state_id, region_id, country_id}, features) do
    cities_ids = Enum.map(cities, & &1.id)

    {features, cities_geojson} = extract_cities(cities_ids, features)

    file_path = Path.join(@dir, "#{country_id}/#{region_id}/#{state_id}/#{health_region_id}/cities.geojson")

    cities_geojson
    |> Jason.encode!()
    |> write_geojson(file_path)

    features
  end

  defp extract_cities(cities_ids, features) do
    {cities_features, features} = Enum.split_with(features, &filter_feature(&1, cities_ids))
    {features, %{"type" => "FeatureCollection", "features" => Enum.map(cities_features, &sanitize_feature/1)}}
  end

  defp filter_feature(%{"attributes" => %{"regiao_saude.id" => city_id}}, cities_ids) do
    city_id in cities_ids
  end

  defp sanitize_feature(%{"geometry" => %{"rings" => rings}, "attributes" => %{"regiao_saude.id" => city_id}}) do
    %{"geometry" => %{"type" => "Polygon", "coordinates" => rings}, "type" => "Feature", "id" => city_id}
  end

  defp write_geojson(geojson, file_path) do
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, geojson)
  end
end

HealthBoard.Scripts.GeoJSON.CitiesFromHealthRegions.run()
