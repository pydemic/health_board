defmodule HealthBoard.Release.DataManager.Locations do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "geo"
  @table_name "locations"
  @columns ~w[context parent_id id name abbr]a

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
