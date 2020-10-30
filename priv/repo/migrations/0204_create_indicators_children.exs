defmodule HealthBoard.Repo.Migrations.CreateIndicatorsChildren do
  use Ecto.Migration

  def change do
    create table(:indicators_children) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :child_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:indicators_children, [:indicator_id, :child_id])
  end
end
