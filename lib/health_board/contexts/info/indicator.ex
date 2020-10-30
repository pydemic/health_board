defmodule HealthBoard.Contexts.Info.Indicator do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.Indicator

  @primary_key {:id, :string, autogenerate: false}
  schema "indicators" do
    field :name, :string
    field :description, :string
    field :math, :string

    has_many :children, Info.IndicatorChild
    has_many :filters, Info.IndicatorFilter
    has_many :sources, Info.IndicatorSource
  end

  @spec changeset(%Indicator{}, map()) :: Ecto.Changeset.t()
  def changeset(indicator, attrs) do
    indicator
    |> cast(attrs, [:id, :name, :description, :math])
    |> validate_required([:id, :name, :description])
    |> unique_constraint([:id])
  end
end
