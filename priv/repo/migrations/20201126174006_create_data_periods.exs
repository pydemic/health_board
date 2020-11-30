defmodule HealthBoard.Repo.Migrations.CreateDataPeriods do
  use Ecto.Migration

  def change do
    create table(:data_periods) do
      add :context, :integer, null: false

      add :from_date, :date, null: false
      add :to_date, :date, null: false

      add :extraction_date, :date, null: false

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
