defmodule HealthBoard.Repo.Migrations.SeedHealthInstitutions do
  use Ecto.Migration

  @context "logistics"
  @table_name "health_institutions"
  @fields [:city_id, :id, :name]

  def up do
    HealthBoard.DataManager.copy!(@context, @table_name, @fields)
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end
end
