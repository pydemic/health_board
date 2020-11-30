defmodule HealthBoard.Repo.Migrations.SeedDataPeriods do
  use Ecto.Migration

  @context "info"
  @table_name "data_periods"
  @fields [:context, :location_id, :from_date, :to_date, :extraction_date]

  def up do
    HealthBoard.DataManager.copy!(@context, @table_name, @fields)
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end
end
