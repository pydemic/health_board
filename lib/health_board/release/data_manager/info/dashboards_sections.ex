defmodule HealthBoard.Release.DataManager.DashboardsSections do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "info"
  @table_name "dashboards_sections"
  @columns ~w[dashboard_id section_id]a

  @spec up :: :ok
  def up do
    DataManager.copy!(@context, @table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
