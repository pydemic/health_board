defmodule HealthBoard.Release.DataManager.SectionsCardsFilters do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "info"
  @table_name "sections_cards_filters"
  @columns ~w[section_card_id filter value]a

  @spec up :: :ok
  def up do
    DataManager.copy!(@context, @table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
