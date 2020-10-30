defmodule HealthBoard.Repo.Migrations.CreateDashboardsIndicators do
  use Ecto.Migration

  def change do
    create table(:dashboards_indicators) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string),
        null: false

      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:dashboards_indicators, [:dashboard_id, :indicator_id])
  end
end
