defmodule HealthBoard.Repo.Migrations.SeedInfo do
  use Ecto.Migration

  alias HealthBoard.Release.DataManager

  def up do
    # DataManager.DataPeriods.up()
    DataManager.Dashboards.up()
    DataManager.Indicators.up()
    DataManager.Sections.up()
    DataManager.Sources.up()
    DataManager.Cards.up()
    DataManager.DashboardsDisabledFilters.up()
    DataManager.DashboardsSections.up()
    DataManager.IndicatorsChildren.up()
    DataManager.IndicatorsSources.up()
    DataManager.SectionsCards.up()
    DataManager.SectionsCardsFilters.up()
  end

  def down do
    DataManager.SectionsCardsFilters.down()
    DataManager.SectionsCards.down()
    DataManager.IndicatorsSources.down()
    DataManager.IndicatorsChildren.down()
    DataManager.DashboardsSections.down()
    DataManager.DashboardsDisabledFilters.down()
    DataManager.Cards.down()
    DataManager.Sources.down()
    DataManager.Sections.down()
    DataManager.Indicators.down()
    DataManager.Dashboards.down()
    # DataManager.DataPeriods.down()
  end
end
