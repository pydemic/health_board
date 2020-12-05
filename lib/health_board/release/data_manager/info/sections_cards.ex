defmodule HealthBoard.Release.DataManager.SectionsCards do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "info"
  @table_name "sections_cards"
  @columns ~w[section_id card_id id name link]a

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
