defmodule HealthBoard.Contexts.Info.IndicatorVisualization do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.IndicatorVisualization

  @primary_key {:id, :string, autogenerate: false}
  schema "indicators_visualizations" do
    field :name, :string
    field :description, :string

    belongs_to :indicator, Info.Indicator, type: :string
    belongs_to :visualization, Info.Visualization, type: :string
  end

  @spec changeset(%IndicatorVisualization{}, map()) :: Ecto.Changeset.t()
  def changeset(indicator_visualization, attrs) do
    indicator_visualization
    |> cast(attrs, [:id, :name, :description, :indicator_id, :visualization_id])
    |> validate_required([:id, :name, :description, :indicator_id, :visualization_id])
    |> unique_constraint([:id, :indicator_id, :visualization_id])
  end
end
