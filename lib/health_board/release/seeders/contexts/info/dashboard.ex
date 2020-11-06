defmodule HealthBoard.Release.Seeders.Contexts.Info.Dashboard do
  require Logger
  alias HealthBoard.Contexts.Info.Dashboard
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/dashboards.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    naive_datetime = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    InsertAllCSVSeeder.seed(@path, Dashboard, &parse(&1, naive_datetime), opts)
  end

  defp parse([id, name, description], naive_datetime) do
    %{
      id: id,
      name: name,
      description: description,
      inserted_at: naive_datetime,
      updated_at: naive_datetime
    }
  end
end
