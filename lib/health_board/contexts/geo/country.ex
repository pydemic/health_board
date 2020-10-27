defmodule HealthBoard.Contexts.Geo.Country do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Geo.Country

  @primary_key {:id, :integer, autogenerate: false}
  schema "countries" do
    field :name, :string
    field :abbr, :string

    field :lat, :float
    field :lng, :float

    has_many :regions, Geo.Region
    has_many :states, Geo.State
    has_many :health_regions, Geo.HealthRegion
    has_many :cities, Geo.City
  end

  @doc false
  @spec changeset(%Country{}, map()) :: Ecto.Changeset.t()
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:id, :name, :abbr, :lat, :lng])
    |> validate_required([:id, :name, :abbr])
    |> unique_constraint(:id)
  end
end
