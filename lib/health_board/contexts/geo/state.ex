defmodule HealthBoard.Contexts.Geo.State do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.State

  @primary_key {:id, :integer, autogenerate: false}
  schema "states" do
    field :name, :string
    field :abbr, :string

    field :lat, :float
    field :lng, :float

    belongs_to :region, Geo.Region
    belongs_to :country, Geo.Country

    has_many :heath_regions, Geo.HealthRegion
    has_many :cities, Geo.City
  end

  @doc false
  @spec changeset(%State{}, map()) :: Ecto.Changeset.t()
  def changeset(state, attrs) do
    state
    |> cast(attrs, [:id, :name, :abbr, :lat, :lng, :name, :region_id])
    |> validate_required([:id, :name, :abbr, :region_id])
    |> unique_constraint(:id)
    |> maybe_add_parents_of_parent()
  end

  defp maybe_add_parents_of_parent(changeset) do
    if changeset.valid? do
      %{country_id: country_id} = Geo.Regions.get!(changeset.changes.region_id)

      put_change(changeset, :country_id, country_id)
    else
      changeset
    end
  end
end
