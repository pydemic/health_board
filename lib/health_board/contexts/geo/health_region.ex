defmodule HealthBoard.Contexts.Geo.HealthRegion do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.HealthRegion

  @primary_key {:id, :integer, autogenerate: false}
  schema "health_regions" do
    field :name, :string
    field :abbr, :string

    field :lat, :float
    field :lng, :float

    belongs_to :state, Geo.State
    belongs_to :region, Geo.Region
    belongs_to :country, Geo.Country

    has_many :cities, Geo.City
  end

  @doc false
  @spec changeset(%HealthRegion{}, map()) :: Ecto.Changeset.t()
  def changeset(health_region, attrs) do
    health_region
    |> cast(attrs, [:id, :name, :abbr, :lat, :lng, :state_id])
    |> validate_required([:id, :name, :state_id])
    |> unique_constraint(:id)
    |> maybe_add_parents_of_parent()
  end

  defp maybe_add_parents_of_parent(changeset) do
    if changeset.valid? do
      %{region_id: region_id, country_id: country_id} = Geo.States.get!(changeset.changes.state_id)

      changeset
      |> put_change(:region_id, region_id)
      |> put_change(:country_id, country_id)
    else
      changeset
    end
  end
end
