defmodule HealthBoard.Contexts.Info.Source do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3]

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "sources" do
    field :name, :string
    field :description, :string

    field :link, :string

    field :update_rate, :string

    field :last_update_date, :date
    field :extraction_date, :date
  end

  @spec changeset(struct, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:last_update_date, :extraction_date])
  end
end
