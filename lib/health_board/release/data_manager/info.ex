defmodule HealthBoard.Release.DataManager.Info do
  alias HealthBoard.Release.DataManager

  @spec reseed :: :ok
  def reseed do
    DataManager.SectionsCardsFilters.down()
    DataManager.SectionsCards.down()
    DataManager.IndicatorsSources.down()
    DataManager.IndicatorsChildren.down()
    DataManager.Cards.down()
    DataManager.Sections.down()
    DataManager.Groups.down()
    DataManager.Sources.down()
    DataManager.Indicators.down()
    DataManager.Dashboards.down()
    DataManager.DataPeriods.down()

    DataManager.DataPeriods.up()
    DataManager.Dashboards.up()
    DataManager.Indicators.up()
    DataManager.Sources.up()
    DataManager.Groups.up()
    DataManager.Sections.up()
    DataManager.Cards.up()
    DataManager.IndicatorsChildren.up()
    DataManager.IndicatorsSources.up()
    DataManager.SectionsCards.up()
    DataManager.SectionsCardsFilters.up()
  end
end
