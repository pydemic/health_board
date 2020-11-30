defmodule HealthBoard.Repo.Migrations.CreateDataPeriodsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:data_periods, [:location_id, :context])
  end
end
