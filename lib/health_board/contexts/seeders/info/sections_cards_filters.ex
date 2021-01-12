defmodule HealthBoard.Contexts.Seeders.SectionsCardsFilters do
  alias HealthBoard.Contexts.Seeder

  @context "info"
  @table_name "sections_cards_filters"
  @columns ~w[section_card_id filter value]a

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    down!()
    up!(base_path)
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csv_from_context!(@context, @table_name, @columns, base_path)
end
