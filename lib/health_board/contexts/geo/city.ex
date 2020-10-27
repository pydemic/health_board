defmodule HealthBoard.Contexts.Geo.City do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.City

  @primary_key {:id, :integer, autogenerate: false}
  schema "cities" do
    field :name, :string
    field :abbr, :string

    field :lat, :float
    field :lng, :float

    belongs_to :health_region, Geo.HealthRegion
    belongs_to :state, Geo.State
    belongs_to :region, Geo.Region
    belongs_to :country, Geo.Country
  end

  @doc false
  @spec changeset(%City{}, map()) :: Ecto.Changeset.t()
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:id, :name, :abbr, :lat, :lng, :health_region_id])
    |> validate_required([:id, :name, :health_region_id])
    |> unique_constraint(:id)
    |> maybe_add_parents_of_parent()
  end

  defp maybe_add_parents_of_parent(changeset) do
    if changeset.valid? do
      health_region_id = changeset.changes.health_region_id

      %{state_id: state_id, region_id: region_id, country_id: country_id} = Geo.HealthRegions.get!(health_region_id)

      changeset
      |> put_change(:state_id, state_id)
      |> put_change(:region_id, region_id)
      |> put_change(:country_id, country_id)
    else
      changeset
    end
  end
end
