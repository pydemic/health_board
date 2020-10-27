defmodule HealthBoard.Contexts.Info.IndicatorFilter do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.IndicatorFilter

  schema "indicators_filters" do
    belongs_to :indicator, Info.Indicator
    belongs_to :filter, Info.Filter
  end

  @spec changeset(%IndicatorFilter{}, map()) :: Ecto.Changeset.t()
  def changeset(indicator_filter, attrs) do
    indicator_filter
    |> cast(attrs, [:indicator_id, :filter_id])
    |> validate_required([:indicator_id, :filter_id])
  end
end
