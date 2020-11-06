defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardFilter do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardFilter
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/dashboards_filters.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, DashboardFilter, &parse/1, opts)
  end

  defp parse([dashboard_id, filter_id, value]) do
    %{
      value: value,
      dashboard_id: dashboard_id,
      filter_id: filter_id
    }
  end
end
