defmodule HealthBoard.Release.Seeders.Contexts.Logistics.HealthInstitution do
  require Logger
  alias HealthBoard.Contexts.Logistics.HealthInstitution
  alias HealthBoard.Release.Seeders.Seeder

  @batch_size 5_000
  @path "logistics/health_institutions.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts =
      opts
      |> Keyword.put(:batch_size, @batch_size)
      |> Keyword.put(:skip_headers, true)

    Seeder.seed(@path, HealthInstitution, &parse/2, opts)
  end

  defp parse([city_id, id, name], _file_name) do
    %{
      city_id: String.to_integer(city_id),
      id: String.to_integer(id),
      name: name
    }
  end
end
