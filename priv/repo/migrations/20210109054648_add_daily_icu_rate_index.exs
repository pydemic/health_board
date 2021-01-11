defmodule HealthBoard.Repo.Migrations.AddDailyICURateIndex do
  use Ecto.Migration

  def change do
    create unique_index(:daily_icu_rate, [:date, :location_id])
  end
end
