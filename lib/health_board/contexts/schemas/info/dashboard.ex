defmodule HealthBoard.Contexts.Info.Dashboard do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "dashboards" do
    field :name, :string
    field :description, :string

    has_many :sections, Info.DashboardSection
    has_many :disabled_filters, Info.DashboardDisabledFilter

    timestamps()
  end
end
