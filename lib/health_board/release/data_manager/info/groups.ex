defmodule HealthBoard.Release.DataManager.Groups do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "info"
  @table_name "groups"
  @columns ~w[dashboard_id index id name description]a

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
