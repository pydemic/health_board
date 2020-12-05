defmodule HealthBoard.Contexts.Info.Source do
  use Ecto.Schema

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "sources" do
    field :name, :string
    field :description, :string

    field :link, :string

    field :update_rate, :string

    field :extraction_date, :date
  end
end
