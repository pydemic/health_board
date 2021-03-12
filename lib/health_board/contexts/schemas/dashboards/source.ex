defmodule HealthBoard.Contexts.Dashboards.Source do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards
  import Ecto.Changeset, only: [cast: 3]

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "sources" do
    field :sid, :string, null: false

    field :name, :string, null: false
    field :description, :string

    field :link, :string
    field :update_rate, :string

    field :extraction_date, :date
    field :last_update_date, :date

    has_many :elements, Dashboards.ElementSource
  end

  @spec changeset(struct, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:last_update_date, :extraction_date])
  end
end
