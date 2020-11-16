defmodule HealthBoard.Repo.Migrations.CreateYearlyVaccinesCoverages do
  use Ecto.Migration

  def change do
    create table(:yearly_vaccines_coverages) do
      add :year, :integer, null: false

      add :bcg, :float, default: 0.0
      add :double_adult_triple_acellular_pregnant, :float, default: 0.0
      add :dtp_ref_4_6_years, :float, default: 0.0
      add :dtp, :float, default: 0.0
      add :dtpa_pregnant, :float, default: 0.0
      add :haemophilus_influenzae_b, :float, default: 0.0
      add :hepatitis_a, :float, default: 0.0
      add :hepatitis_b_at_most_30_days_children, :float, default: 0.0
      add :hepatitis_b, :float, default: 0.0
      add :human_rotavirus, :float, default: 0.0
      add :measles, :float, default: 0.0
      add :meningococcus_c_1st_reference, :float, default: 0.0
      add :meningococcus_c, :float, default: 0.0
      add :pentavalent, :float, default: 0.0
      add :pneumococcal_1st_reference, :float, default: 0.0
      add :pneumococcal, :float, default: 0.0
      add :polio_1st_reference, :float, default: 0.0
      add :polio_4_years, :float, default: 0.0
      add :polio, :float, default: 0.0
      add :tetra_viral, :float, default: 0.0
      add :tetravalent, :float, default: 0.0
      add :triple_bacterial, :float, default: 0.0
      add :triple_viral_d1, :float, default: 0.0
      add :triple_viral_d2, :float, default: 0.0
      add :yellow_fever, :float, default: 0.0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end
end
