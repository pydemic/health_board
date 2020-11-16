defmodule HealthBoard.Repo.Migrations.AddYearlyLocationsBirthsIndexes do
  use Ecto.Migration

  @location_contexts Enum.with_index(~w[resident source])
  @locations [
    {"brasil", {:exact, 76}},
    {"regions", {:magnitude, 1}},
    {"states", {:magnitude, 10}},
    {"health_regions", {:magnitude, 10_000}},
    {"cities", {:magnitude, 1_000_000}}
  ]

  def change do
    create unique_index(
             :yearly_locations_births,
             [:location_context, :location_id, :year],
             name: :yearly_locations_births_unique_index
           )

    Enum.each(@location_contexts, &create_contexts_indexes/1)
  end

  defp create_contexts_indexes({context, context_index}) do
    Enum.each(@locations, &create_location_index(&1, context, context_index))
  end

  defp create_location_index({level, location_condition}, context, context_index) do
    create index(
             :yearly_locations_births,
             [:location_context, :location_id, :year],
             where: where_conditions(location_condition, context_index),
             name: "#{context}_#{level}_yearly_births_index"
           )
  end

  defp where_conditions({:exact, value}, context_index) do
    Enum.join(
      [
        "location_context = #{context_index}",
        "location_id = #{value}"
      ],
      " AND "
    )
  end

  defp where_conditions({:magnitude, value}, context_index) do
    Enum.join(
      [
        "location_context = #{context_index}",
        "location_id >= #{value}",
        "location_id < #{value * 10 - 1}"
      ],
      " AND "
    )
  end
end
