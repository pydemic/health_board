defmodule HealthBoard.Repo.Migrations.CreateDashboards do
  use Ecto.Migration

  def change do
    create_elements()
    create_elements_children()

    create_elements_data()

    create_filters()
    create_elements_filters()

    create_indicators()
    create_elements_indicators()

    create_sources()
    create_elements_sources()
  end

  defp create_elements do
    create table(:elements) do
      add :type, :integer, null: false

      add :name, :string, null: false
      add :description, :text

      add :component_module, :string, null: false
      add :component_function, :string, null: false
      add :component_params, :text

      add :link_element_id, references(:elements, on_delete: :nilify_all)
    end
  end

  defp create_elements_children do
    create table(:elements_children) do
      add :parent_id, references(:elements, on_delete: :delete_all), null: false
      add :child_id, references(:elements, on_delete: :delete_all), null: false
    end
  end

  defp create_elements_data do
    create table(:elements_data) do
      add :field, :string, null: false

      add :data_module, :string, null: false
      add :data_function, :string, null: false
      add :data_params, :text

      add :element_id, references(:elements, on_delete: :delete_all), null: false
    end
  end

  defp create_filters do
    create table(:filters) do
      add :title, :string, null: false
      add :description, :text

      add :default, :text

      add :disabled, :boolean, default: false

      add :options_module, :string, null: false
      add :options_function, :string, null: false
      add :options_params, :text
    end
  end

  defp create_elements_filters do
    create table(:elements_filters) do
      add :default, :text

      add :disabled, :boolean

      add :options_module, :string
      add :options_function, :string
      add :options_params, :text

      add :element_id, references(:elements, on_delete: :delete_all), null: false
      add :filter_id, references(:filters, on_delete: :delete_all), null: false
    end
  end

  defp create_indicators do
    create table(:indicators) do
      add :description, :text, null: false

      add :formula, :text, null: false
      add :measurement_unit, :string

      add :link, :text
    end
  end

  defp create_elements_indicators do
    create table(:elements_indicators) do
      add :element_id, references(:elements, on_delete: :delete_all), null: false
      add :indicator_id, references(:indicators, on_delete: :delete_all), null: false
    end
  end

  defp create_sources do
    create table(:sources) do
      add :name, :string, null: false
      add :description, :text

      add :link, :text
      add :update_rate, :string

      add :extraction_date, :date
      add :last_update_date, :date
    end
  end

  defp create_elements_sources do
    create table(:elements_sources) do
      add :element_id, references(:elements, on_delete: :delete_all), null: false
      add :source_id, references(:sources, on_delete: :delete_all), null: false
    end
  end
end
