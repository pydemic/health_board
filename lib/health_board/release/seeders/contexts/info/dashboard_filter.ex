defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardFilter do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardFilter
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/dashboards_filters.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, DashboardFilter, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([dashboard_id, filter_id, value], _file_name) do
    %{
      value: value,
      dashboard_id: dashboard_id,
      filter_id: filter_id
    }
  end
end
