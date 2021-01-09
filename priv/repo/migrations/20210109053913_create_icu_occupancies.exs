defmodule HealthBoard.Repo.Migrations.CreateICUOccupancies do
  use Ecto.Migration

  def change do
    create_daily_icu_occupancies()
  end

  defp create_daily_icu_occupancies do
    create table(:daily_icu_occupancies) do
      add :date, :date, null: false
      add :rate, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
