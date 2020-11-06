defmodule HealthBoard.Contexts.Info.DashboardIndicatorVisualization do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.DashboardIndicatorVisualization

  schema "dashboards_indicators_visualizations" do
    belongs_to :dashboard, Info.Dashboard, type: :string
    belongs_to :indicator_visualization, Info.IndicatorVisualization, type: :string
  end

  @spec changeset(%DashboardIndicatorVisualization{}, map()) :: Ecto.Changeset.t()
  def changeset(dashboard_indicator_visualization, attrs) do
    dashboard_indicator_visualization
    |> cast(attrs, [:dashboard_id, :indicator_visualization_id])
    |> validate_required([:dashboard_id, :indicator_visualization_id])
    |> unique_constraint([:dashboard_id, :indicator_visualization_id])
  end
end
