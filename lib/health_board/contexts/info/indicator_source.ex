defmodule HealthBoard.Contexts.Info.IndicatorSource do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.IndicatorSource

  schema "indicators_sources" do
    belongs_to :indicator, Info.Indicator
    belongs_to :source, Info.Source
  end

  @spec changeset(%IndicatorSource{}, map()) :: Ecto.Changeset.t()
  def changeset(indicator_source, attrs) do
    indicator_source
    |> cast(attrs, [:indicator_id, :source_id])
    |> validate_required([:indicator_id, :source_id])
  end
end
