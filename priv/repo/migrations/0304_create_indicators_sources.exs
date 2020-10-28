defmodule HealthBoard.Repo.Migrations.CreateIndicatorsSources do
  use Ecto.Migration

  def change do
    create table(:indicators_sources) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string),
        null: false

      add :source_id, references(:sources, on_delete: :delete_all, type: :string), null: false
    end
  end
end
