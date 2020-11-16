defmodule HealthBoard.Contexts.Info.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.Card

  @primary_key {:id, :string, autogenerate: false}
  schema "cards" do
    field :name, :string
    field :description, :string

    belongs_to :indicator, Info.Indicator, type: :string
    belongs_to :format, Info.Format, type: :string
  end

  @spec changeset(%Card{}, map()) :: Ecto.Changeset.t()
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :name, :description, :indicator_id, :format_id])
    |> validate_required([:id, :name, :description, :indicator_id, :format_id])
    |> unique_constraint([:id, :indicator_id, :format_id])
  end
end
