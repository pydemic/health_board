defmodule HealthBoardWeb.Helpers.Geo do
  @ets_features :health_board_web_helpers_map_locations_features

  # setup

  @spec init :: :ok
  def init do
    :ets.new(@ets_features, [:set, :public, :named_table])

    :health_board
    |> Application.fetch_env!(:data_path)
    |> Path.join("geojson")
    |> fetch_features()
  end

  defp fetch_features(path) do
    path
    |> File.ls!()
    |> Enum.each(&fetch_feature(Path.join(path, &1)))
  end

  defp fetch_feature(path) do
    if File.dir?(path) do
      fetch_features(path)
    else
      path
      |> File.read!()
      |> Jason.decode!(keys: :atoms)
      |> case do
        %{type: "FeatureCollection", features: features} -> Enum.each(features, &add_feature_to_ets/1)
        %{type: "Feature"} = feature -> add_feature_to_ets(feature)
        _map -> :ok
      end
    end
  end

  defp add_feature_to_ets(%{properties: %{id: id}} = feature), do: :ets.insert(@ets_features, {id, feature})
  defp add_feature_to_ets(_feature), do: :ok

  # features

  @spec build_feature_collection(list(map)) :: map
  def build_feature_collection(properties) do
    %{type: "FeatureCollection", features: Enum.reduce(properties, [], &build_feature/2)}
  end

  defp build_feature(properties, features) do
    with {:ok, id} <- Map.fetch(properties, :id),
         [{_id, feature} | _tail] <- :ets.lookup(@ets_features, id) do
      [Map.put(feature, :properties, properties) | features]
    else
      _ -> features
    end
  end
end
