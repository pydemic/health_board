defmodule HealthBoard.Contexts.Seeders.Geo do
  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :locations, :locations_children] do
      __MODULE__.LocationsChildren.down!()
      __MODULE__.Locations.down!()
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
      __MODULE__.Locations.up!(base_path)
      __MODULE__.LocationsChildren.up!(base_path)
    end

    :ok
  end
end
