defmodule HealthBoard.Contexts.Info.DashboardDisabledFilter do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  schema "dashboards_disabled_filters" do
    field :filter, :string

    belongs_to :dashboard, Info.Dashboard, type: :string
  end
end
