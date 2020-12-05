defmodule HealthBoard.Repo.Migrations.CreateInfo do
  use Ecto.Migration

  def change do
    create table(:data_periods) do
      add :context, :integer, null: false

      add :from_date, :date, null: false
      add :to_date, :date, null: false

      add :extraction_date, :date, null: false

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end

    create table(:dashboards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create table(:indicators, primary_key: false) do
      add :id, :string, primary_key: true

      add :description, :text
      add :formula, :text
      add :measurement_unit, :string
      add :reference, :text
    end

    create table(:sections, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :description, :text
    end

    create table(:sources, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string, null: false
      add :description, :text
      add :link, :text
      add :update_rate, :string

      add :extraction_date, :date
    end

    create table(:cards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string, null: false
      add :description, :text

      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create table(:dashboards_disabled_filters) do
      add :filter, :string, null: false

      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string), null: false
    end

    create table(:dashboards_sections) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all, type: :string), null: false
      add :section_id, references(:sections, on_delete: :delete_all, type: :string), null: false
    end

    create table(:indicators_children) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
      add :child_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
    end

    create table(:indicators_sources) do
      add :indicator_id, references(:indicators, on_delete: :delete_all, type: :string), null: false
      add :source_id, references(:sources, on_delete: :delete_all, type: :string), null: false
    end

    create table(:sections_cards, primary_key: false) do
      add :id, :string, primary_key: true

      add :name, :string
      add :link, :boolean

      add :section_id, references(:sections, on_delete: :delete_all, type: :string), null: false
      add :card_id, references(:cards, on_delete: :delete_all, type: :string), null: false
    end

    create table(:sections_cards_filters) do
      add :filter, :string, null: false
      add :value, :text, null: false

      add :section_card_id, references(:sections_cards, on_delete: :delete_all, type: :string), null: false
    end
  end
end
