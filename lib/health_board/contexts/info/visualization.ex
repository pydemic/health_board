defmodule HealthBoard.Contexts.Info.Visualization do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info.Visualization

  @primary_key {:id, :string, autogenerate: false}
  schema "visualizations" do
    field :name, :string
    field :description, :string
  end

  @spec changeset(%Visualization{}, map()) :: Ecto.Changeset.t()
  def changeset(visualization, attrs) do
    visualization
    |> cast(attrs, [:id, :name, :description])
    |> validate_required([:id, :name, :description])
    |> unique_constraint([:id])
  end
end
