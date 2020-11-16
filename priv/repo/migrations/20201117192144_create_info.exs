defmodule HealthBoard.Repo.Migrations.CreateInfo do
  use Ecto.Migration

  def change do
    create table(:dashboards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      timestamps()
    end

    create table(:filters, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
    end

    create table(:formats, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string
    end

    create table(:indicators, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :math, :string
    end

    create table(:dashboards_filters) do
      add :value, :string

      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string), null: false
      add :filter_id, references(:filters, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:dashboards_filters, [:dashboard_id, :filter_id])

    create table(:indicators_children) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
      add :child_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:indicators_children, [:indicator_id, :child_id])

    create table(:cards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :string

      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false

      add :format_id, references(:formats, on_delete: :delete_all, type: :string), null: false
    end

    create table(:dashboards_cards) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string), null: false

      add :card_id, references(:cards, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:dashboards_cards, [:dashboard_id, :card_id])
  end
end
