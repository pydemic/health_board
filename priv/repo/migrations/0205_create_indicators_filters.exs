defmodule HealthBoard.Repo.Migrations.CreateIndicatorsFilters do
  use Ecto.Migration

  def change do
    create table(:indicators_filters) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :filter_id, references(:filters, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:indicators_filters, [:indicator_id, :filter_id])
  end
end
