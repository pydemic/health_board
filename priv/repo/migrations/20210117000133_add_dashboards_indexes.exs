defmodule HealthBoard.Repo.Migrations.AddDashboardsIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:elements, :sid)
    create unique_index(:elements_children, [:parent_id, :child_id])
    create unique_index(:elements_filters, [:element_id, :filter_id])
    create unique_index(:elements_indicators, [:element_id, :indicator_id])
    create unique_index(:elements_sources, [:element_id, :source_id])
    create unique_index(:filters, :sid)
    create unique_index(:indicators, :sid)
    create unique_index(:sources, :sid)
  end
end
