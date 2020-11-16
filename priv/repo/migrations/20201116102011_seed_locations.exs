defmodule HealthBoard.Repo.Migrations.SeedLocations do
  use Ecto.Migration

  @context "geo"
  @table_name "locations"
  @fields [:level, :parent_id, :id, :name, :abbr]

  def up do
    HealthBoard.DataManager.copy!(@context, @table_name, @fields)
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end
end
