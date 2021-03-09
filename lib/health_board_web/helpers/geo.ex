defmodule HealthBoardWeb.Helpers.Geo do
  @ets_features :health_board_web_helpers_map_locations_features
  @temporary_dir "/tmp/health_board/geo/feature_collections"

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

  @spec find_file_path(String.t()) :: {:ok, String.t()} | :error
  def find_file_path(filename) do
    path = Path.join(@temporary_dir, "#{filename}.geojson")

    if File.exists?(path) do
      {:ok, path}
    else
      :error
    end
  end

  @spec build_feature_collection(list(map)) :: {:ok, String.t()} | :error
  def build_feature_collection(properties) do
    with [_ | _] = features <- Enum.reduce(properties, [], &build_feature/2),
         {:ok, feature_collection} <- Jason.encode(%{type: "FeatureCollection", features: features}),
         :ok <- File.mkdir_p(@temporary_dir),
         now <- DateTime.to_iso8601(DateTime.utc_now(), :basic),
         :ok <- File.write(Path.join(@temporary_dir, "#{now}.geojson"), feature_collection) do
      {:ok, now}
    else
      _result -> :error
    end
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
