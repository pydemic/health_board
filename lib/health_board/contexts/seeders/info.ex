defmodule HealthBoard.Contexts.Seeders.Info do
  alias HealthBoard.Contexts.Seeders

  @spec down!(keyword) :: :ok
  def down!(opts \\ []) do
    what = Keyword.get(opts, :what, :all)

    if what == :all do
      Seeders.SectionsCardsFilters.down!()
      Seeders.SectionsCards.down!()
      Seeders.IndicatorsSources.down!()
      Seeders.IndicatorsChildren.down!()
      Seeders.Cards.down!()
      Seeders.Sections.down!()
      Seeders.Groups.down!()
      Seeders.Sources.down!()
      Seeders.Indicators.down!()
      Seeders.Dashboards.down!()
      Seeders.DataPeriods.down!()
    else
      if what == :data_periods, do: Seeders.DataPeriods.down!()

      if what == :dashboards do
        Seeders.SectionsCardsFilters.down!()
        Seeders.SectionsCards.down!()
        Seeders.IndicatorsSources.down!()
        Seeders.IndicatorsChildren.down!()
        Seeders.Cards.down!()
        Seeders.Sections.down!()
        Seeders.Groups.down!()
        Seeders.Sources.down!()
        Seeders.Indicators.down!()
        Seeders.Dashboards.down!()
      end
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

    if what == :all do
      Seeders.DataPeriods.up!(base_path)
      Seeders.Dashboards.up!(base_path)
      Seeders.Indicators.up!(base_path)
      Seeders.Sources.up!(base_path)
      Seeders.Groups.up!(base_path)
      Seeders.Sections.up!(base_path)
      Seeders.Cards.up!(base_path)
      Seeders.IndicatorsChildren.up!(base_path)
      Seeders.IndicatorsSources.up!(base_path)
      Seeders.SectionsCards.up!(base_path)
      Seeders.SectionsCardsFilters.up!(base_path)
    else
      if what == :data_periods, do: Seeders.DataPeriods.up!(base_path)

      if what == :dashboards do
        Seeders.Dashboards.up!(base_path)
        Seeders.Indicators.up!(base_path)
        Seeders.Sources.up!(base_path)
        Seeders.Groups.up!(base_path)
        Seeders.Sections.up!(base_path)
        Seeders.Cards.up!(base_path)
        Seeders.IndicatorsChildren.up!(base_path)
        Seeders.IndicatorsSources.up!(base_path)
        Seeders.SectionsCards.up!(base_path)
        Seeders.SectionsCardsFilters.up!(base_path)
      end
    end

    :ok
  end
end
