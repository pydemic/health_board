defmodule HealthBoard.Repo.Migrations.CreateDashboardsFilters do
  use Ecto.Migration

  def change do
    create table(:dashboards_filters) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string),
        null: false

      add :filter_id, references(:filters, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:dashboards_filters, [:dashboard_id, :filter_id])
  end
end
