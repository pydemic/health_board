defmodule HealthBoard.Repo.Migrations.SeedInfo do
  use Ecto.Migration

  @context "info"
  @tables [
    {"dashboards", ~w[id name description inserted_at updated_at]a},
    {"filters", ~w[id name]a},
    {"formats", ~w[id name description]a},
    {"indicators", ~w[id name description math]a},
    {"dashboards_filters", ~w[dashboard_id filter_id value]a},
    {"indicators_children", ~w[indicator_id child_id]a},
    {"cards", ~w[indicator_id id format_id name description]a},
    {"dashboards_cards", ~w[dashboard_id card_id]a}
  ]

  def up do
    Enum.each(@tables, &HealthBoard.DataManager.copy!(@context, elem(&1, 0), elem(&1, 1)))
  end

  def down do
    Enum.each(@tables, &HealthBoard.Repo.query!("TRUNCATE #{elem(&1, 0)} CASCADE;"))
  end
end
