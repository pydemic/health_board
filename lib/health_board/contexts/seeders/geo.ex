defmodule HealthBoard.Contexts.Seeders.Geo do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :locations, :locations_children] do
      Seeders.LocationsChildren.down!()
      Seeders.Locations.down!()
    end

    :ok
  end

  @spec reseed!(keyword) :: :ok
  def reseed!(opts \\ []) do
    down!(opts)
    up!(opts)
  end

  @spec up!(keyword) :: :ok
  def up!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)
    base_path = Keyword.get(opts, :base_path)

    if what in [:all, :locations, :locations_children] do
      Seeders.Locations.up!(base_path)
      Seeders.LocationsChildren.up!(base_path)
    end

    :ok
  end
end
