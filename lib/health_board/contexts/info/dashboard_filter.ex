defmodule HealthBoard.Contexts.Info.DashboardFilter do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.DashboardFilter

  schema "dashboards_filters" do
    field :value, :string
    field :type, :string

    belongs_to :dashboard, Info.Dashboard
    belongs_to :filter, Info.Filter
  end

  @spec changeset(%DashboardFilter{}, map()) :: Ecto.Changeset.t()
  def changeset(dashboard_filter, attrs) do
    dashboard_filter
    |> cast(attrs, [:value, :type, :dashboard_id, :filter_id])
    |> validate_required([:dashboard_id, :filter_id])
    |> unique_constraint([:dashboard_id, :filter_id])
  end
end
