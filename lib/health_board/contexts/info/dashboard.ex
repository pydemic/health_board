defmodule HealthBoard.Contexts.Info.Dashboard do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.Dashboard

  @primary_key {:id, :string, autogenerate: false}
  schema "dashboards" do
    field :name, :string
    field :description, :string

    has_many :filters, Info.DashboardFilter
    has_many :indicators_visualizations, Info.DashboardIndicatorVisualization

    timestamps()
  end

  @spec changeset(%Dashboard{}, map()) :: Ecto.Changeset.t()
  def changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:id, :name, :description])
    |> validate_required([:id, :name])
    |> unique_constraint([:id])
  end
end
