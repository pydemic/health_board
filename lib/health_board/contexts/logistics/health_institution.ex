defmodule HealthBoard.Contexts.Logistics.HealthInstitution do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Logistics.HealthInstitution

  @primary_key {:id, :integer, autogenerate: false}
  schema "health_institutions" do
    field :name, :string

    belongs_to :city, Geo.City
  end

  @doc false
  @spec changeset(%HealthInstitution{}, map()) :: Ecto.Changeset.t()
  def changeset(health_institution, attrs) do
    health_institution
    |> cast(attrs, [:id, :name, :city_id])
    |> validate_required([:id, :name, :city_id])
    |> unique_constraint(:id)
  end
end
