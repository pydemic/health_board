defmodule HealthBoard.Contexts.Info.DashboardCard do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.DashboardCard

  schema "dashboards_cards" do
    belongs_to :dashboard, Info.Dashboard, type: :string
    belongs_to :card, Info.Card, type: :string
  end

  @spec changeset(%DashboardCard{}, map()) :: Ecto.Changeset.t()
  def changeset(dashboard_card, attrs) do
    dashboard_card
    |> cast(attrs, [:dashboard_id, :card_id])
    |> validate_required([:dashboard_id, :card_id])
    |> unique_constraint([:dashboard_id, :card_id])
  end
end
