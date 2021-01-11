defmodule HealthBoard.Repo.Migrations.CreateDailyICURate do
  use Ecto.Migration

  def change do
    create table(:daily_icu_rate) do
      add :date, :date, null: false

      add :rate, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
