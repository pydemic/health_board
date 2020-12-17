defmodule HealthBoard.Release.DataManager.LocationsChildren do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "geo"
  @table_name "locations_children"
  @columns ~w[parent_context parent_id child_context child_id]a

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
