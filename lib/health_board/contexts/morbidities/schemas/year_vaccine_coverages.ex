defmodule HealthBoard.Contexts.Morbidities.YearVaccineCoverages do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Morbidities.YearVaccineCoverages
  alias HealthBoard.Contexts.Geo

  schema "yearly_vaccines_coverages" do
    field :location_context, :integer, null: false

    field :year, :integer, null: false

    field :bcg, :float, default: 0.0
    field :double_adult_triple_acellular_pregnant, :float, default: 0.0
    field :dtp_ref_4_6_years, :float, default: 0.0
    field :dtp, :float, default: 0.0
    field :dtpa_pregnant, :float, default: 0.0
    field :haemophilus_influenzae_b, :float, default: 0.0
    field :hepatitis_a, :float, default: 0.0
    field :hepatitis_b_at_most_30_days_children, :float, default: 0.0
    field :hepatitis_b, :float, default: 0.0
    field :human_rotavirus, :float, default: 0.0
    field :measles, :float, default: 0.0
    field :meningococcus_c_1st_reference, :float, default: 0.0
    field :meningococcus_c, :float, default: 0.0
    field :pentavalent, :float, default: 0.0
    field :pneumococcal_1st_reference, :float, default: 0.0
    field :pneumococcal, :float, default: 0.0
    field :polio_1st_reference, :float, default: 0.0
    field :polio_4_years, :float, default: 0.0
    field :polio, :float, default: 0.0
    field :tetra_viral, :float, default: 0.0
    field :tetravalent, :float, default: 0.0
    field :triple_bacterial, :float, default: 0.0
    field :triple_viral_d1, :float, default: 0.0
    field :triple_viral_d2, :float, default: 0.0
    field :yellow_fever, :float, default: 0.0

    belongs_to :location, Geo.Location
  end

  @cast_attrs [
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
    :yellow_fever,
    :location_id
  ]

  @doc false
  @spec changeset(%YearVaccineCoverages{}, map()) :: Ecto.Changeset.t()
  def changeset(year_vaccine_coverages, attrs) do
    year_vaccine_coverages
    |> cast(attrs, @cast_attrs)
    |> validate_required(@cast_attrs)
    |> unique_constraint([:location_id, :year])
  end
end
