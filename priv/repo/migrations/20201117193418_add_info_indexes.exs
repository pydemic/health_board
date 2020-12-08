defmodule HealthBoard.Repo.Migrations.AddInfoIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:data_periods, [:data_context, :context, :location_id])
    create unique_index(:cards, [:id, :indicator_id])
    create unique_index(:dashboards_disabled_filters, [:filter, :dashboard_id])
    create unique_index(:dashboards_sections, [:dashboard_id, :section_id])
    create unique_index(:indicators_children, [:indicator_id, :child_id])
    create unique_index(:indicators_sources, [:indicator_id, :source_id])
    create unique_index(:sections_cards, [:id, :section_id, :card_id])
    create unique_index(:sections_cards_filters, [:filter, :section_card_id])
  end
end
