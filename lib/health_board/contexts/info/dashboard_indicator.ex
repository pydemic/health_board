defmodule HealthBoard.Contexts.Info.DashboardIndicator do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.DashboardIndicator

  schema "dashboards_indicators" do
    belongs_to :dashboard, Info.Dashboard
    belongs_to :indicator, Info.Indicator
  end

  @spec changeset(%DashboardIndicator{}, map()) :: Ecto.Changeset.t()
  def changeset(dashboard_indicator, attrs) do
    dashboard_indicator
    |> cast(attrs, [:dashboard_id, :indicator_id])
    |> validate_required([:dashboard_id, :indicator_id])
    |> unique_constraint([:dashboard_id, :indicator_id])
  end
end
