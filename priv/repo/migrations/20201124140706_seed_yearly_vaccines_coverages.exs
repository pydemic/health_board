defmodule HealthBoard.Repo.Migrations.SeedYearlyVaccinesCoverages do
  use Ecto.Migration

  @context "morbidities"
  @table_name "yearly_vaccines_coverages"
  @fields [
    :location_id,
    :year,
    :bcg,
    :double_adult_triple_acellular_pregnant,
    :dtp_ref_4_6_years,
    :dtp,
    :dtpa_pregnant,
    :haemophilus_influenzae_b,
    :hepatitis_a,
    :hepatitis_b_at_most_30_days_children,
    :hepatitis_b,
    :human_rotavirus,
    :measles,
    :meningococcus_c_1st_reference,
    :meningococcus_c,
    :pentavalent,
    :pneumococcal_1st_reference,
    :pneumococcal,
    :polio_1st_reference,
    :polio_4_years,
    :polio,
    :tetra_viral,
    :tetravalent,
    :triple_bacterial,
    :triple_viral_d1,
    :triple_viral_d2,
    :yellow_fever
  ]

  def up do
    HealthBoard.DataManager.copy!(@context, @table_name, @fields)
  end

  def down do
    HealthBoard.Repo.query!("TRUNCATE #{@table_name} CASCADE;")
  end
end
