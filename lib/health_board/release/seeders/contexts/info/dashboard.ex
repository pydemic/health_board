defmodule HealthBoard.Release.Seeders.Contexts.Info.Dashboard do
  require Logger
  alias HealthBoard.Contexts.Info.Dashboard
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/dashboards.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    naive_datetime = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    Seeder.seed(@path, Dashboard, &parse(&1, &2, naive_datetime), opts)
  end

  defp parse([id, name, description], _file_name, naive_datetime) do
    %{
      id: id,
      name: name,
      description: description,
      inserted_at: naive_datetime,
      updated_at: naive_datetime
    }
  end
end
