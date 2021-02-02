defmodule HealthBoard.Contexts.Seeders.Dashboards do
  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what in [:all, :elements, :elements_children], do: __MODULE__.ElementsChildren.down!()
    if what in [:all, :elements, :data, :elements_data], do: __MODULE__.ElementsData.down!()
    if what in [:all, :elements, :filters, :elements_filters], do: __MODULE__.ElementsFilters.down!()
    if what in [:all, :elements, :indicators, :elements_indicators], do: __MODULE__.ElementsIndicators.down!()
    if what in [:all, :elements, :sources, :elements_sources], do: __MODULE__.ElementsSources.down!()
    if what in [:all, :elements], do: __MODULE__.Elements.down!()

    if what in [:all, :filters], do: __MODULE__.Filters.down!()
    if what in [:all, :indicators], do: __MODULE__.Indicators.down!()
    if what in [:all, :sources], do: __MODULE__.Sources.down!()

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

    if what in [:all, :sources], do: __MODULE__.Sources.up!(base_path)
    if what in [:all, :indicators], do: __MODULE__.Indicators.up!(base_path)
    if what in [:all, :filters], do: __MODULE__.Filters.up!(base_path)

    if what in [:all, :elements], do: __MODULE__.Elements.up!(base_path)
    if what in [:all, :elements, :sources, :elements_sources], do: __MODULE__.ElementsSources.up!(base_path)
    if what in [:all, :elements, :indicators, :elements_indicators], do: __MODULE__.ElementsIndicators.up!(base_path)
    if what in [:all, :elements, :filters, :elements_filters], do: __MODULE__.ElementsFilters.up!(base_path)
    if what in [:all, :elements, :data, :elements_data], do: __MODULE__.ElementsData.up!(base_path)
    if what in [:all, :elements, :elements_children], do: __MODULE__.ElementsChildren.up!(base_path)

    :ok
  end
end
