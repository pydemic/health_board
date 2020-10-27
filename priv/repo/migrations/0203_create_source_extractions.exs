defmodule HealthBoard.Repo.Migrations.CreateSourceExtractions do
  use Ecto.Migration

  def change do
    create table(:source_extractions) do
      add :date, :date

      add :source_id, references(:sources, on_delete: :delete_all, type: :string), null: false
    end
  end
end
