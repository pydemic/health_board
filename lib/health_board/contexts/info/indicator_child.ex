defmodule HealthBoard.Contexts.Info.IndicatorChild do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.IndicatorChild

  schema "indicators_children" do
    belongs_to :indicator, Info.Indicator
    belongs_to :child, Info.Indicator
  end

  @spec changeset(%IndicatorChild{}, map()) :: Ecto.Changeset.t()
  def changeset(indicator_child, attrs) do
    indicator_child
    |> cast(attrs, [:indicator_id, :child_id])
    |> validate_required([:indicator_id, :child_id])
  end
end
