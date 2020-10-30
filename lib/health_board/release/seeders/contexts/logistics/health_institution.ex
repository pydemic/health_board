defmodule HealthBoard.Release.Seeders.Contexts.Logistics.HealthInstitution do
  require Logger
  alias HealthBoard.Contexts.Logistics.HealthInstitution
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @batch_size 5_000
  @path "logistics/health_institutions.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, HealthInstitution, &parse/1, Keyword.put(opts, :batch_size, @batch_size))
  end

  defp parse([city_id, id, name]) do
    %{
      city_id: String.to_integer(city_id),
      id: String.to_integer(id),
      name: name
    }
  end
end
