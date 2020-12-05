defmodule HealthBoard.Contexts.Info.DashboardSection do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  schema "dashboards_sections" do
    belongs_to :dashboard, Info.Dashboard, type: :string
    belongs_to :section, Info.Section, type: :string
  end
end
