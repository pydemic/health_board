defmodule HealthBoard.Contexts.Geo.Region do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.Region

  @primary_key {:id, :integer, autogenerate: false}
  schema "regions" do
    field :name, :string
    field :abbr, :string

    field :lat, :float
    field :lng, :float

    belongs_to :country, Geo.Country

    has_many :states, Geo.State
    has_many :health_regions, Geo.HealthRegion
    has_many :cities, Geo.City
  end

  @doc false
  @spec changeset(%Region{}, map()) :: Ecto.Changeset.t()
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:id, :name, :abbr, :lat, :lng, :country_id])
    |> validate_required([:id, :name, :abbr, :country_id])
    |> unique_constraint(:id)
  end
end
