defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardFilter do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardFilter
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/dashboards_filters.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, DashboardFilter, &parse/2, opts)
  end

  defp parse([filter_id, value], dashboard_id) do
    %{
      value: value,
      dashboard_id: dashboard_id,
      filter_id: filter_id
    }
  end
end
