defmodule HealthBoard.Contexts.Info.SourceExtraction do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.SourceExtraction

  schema "source_extractions" do
    field :date, :date

    belongs_to :source, Info.Source
  end

  @spec changeset(%SourceExtraction{}, map()) :: Ecto.Changeset.t()
  def changeset(source_extraction, attrs) do
    source_extraction
    |> cast(attrs, [:date, :source_id])
    |> validate_required([:date, :source_id])
  end
end
