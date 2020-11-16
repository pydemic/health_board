defmodule HealthBoard.Repo.Migrations.AddYearlyMorbiditiesCasesIndexes do
  use Ecto.Migration

  @diseases_contexts 0..6

  @location_contexts 0..1

  @locations [
    {"brasil", {:exact, 76}},
    {"regions", {:magnitude, 1}},
    {"states", {:magnitude, 10}},
    {"health_regions", {:magnitude, 10_000}},
    {"cities", {:magnitude, 1_000_000}}
  ]

  @tables [
    "botulism",
    "chikungunya",
    "cholera",
    "hantavirus",
    "human_rabies",
    "malaria_from_extra_amazon",
    "plague",
    "spotted_fever",
    "yellow_fever",
    "zika",
    "american_tegumentary_leishmaniasis",
    "chagas",
    "dengue",
    "diphtheria",
    "exogenous_intoxications",
    "leprosy",
    "leptospirosis",
    "meningitis",
    "neonatal_tetanus",
    "poisonous_animals_accidents",
    "schistosomiasis",
    "tetanus_accidents",
    "tuberculosis",
    "violence",
    "visceral_leishmaniasis",
    "whooping_cough"
  ]

  def change do
    create unique_index(
             :yearly_mortalities_cases,
             [:disease_context, :location_context, :location_id, :year],
             name: :yearly_mortalities_cases_unique_index
           )

    Enum.each(@diseases_contexts, &create_disease_context_indexes/1)

    Enum.each(@tables, &create_unique_index/1)
    Enum.each(@location_contexts, &create_location_context_indexes/1)
  end

  defp create_disease_context_indexes(disease_context) do
    Enum.each(@location_contexts, &create_location_context_indexes(&1, disease_context))
  end

  defp create_location_context_indexes(location_context, disease_context \\ nil) do
    if is_nil(disease_context) do
      Enum.each(@tables, &create_table_indexes(&1, location_context))
    else
      create_table_indexes("mortalities", location_context, disease_context)
    end
  end

  defp create_table_indexes(table_name, location_context, disease_context \\ nil) do
    Enum.each(@locations, &create_location_index(&1, table_name, location_context, disease_context))
  end

  defp create_location_index({level, location_condition}, table_name, location_context, disease_context) do
    if is_nil(disease_context) do
      create index(
               "#{table_name}_yearly_cases",
               [:location_context, :location_id, :year],
               where: where_conditions(location_condition, location_context),
               name: "#{location_context}_#{level}_#{table_name}_yc_i"
             )
    else
      create index(
               "yearly_#{table_name}_cases",
               [:disease_context, :location_context, :location_id, :year],
               where: where_conditions(location_condition, location_context, disease_context),
               name: "#{disease_context}_#{location_context}_#{level}_yearly_#{table_name}_cases_index"
             )
    end
  end

  defp where_conditions(location_condition, location_context, disease_context \\ nil)

  defp where_conditions({:exact, value}, location_context, disease_context) do
    Enum.join(
      [
        "location_context = #{location_context}",
        "location_id = #{value}"
      ]
      |> maybe_add_disease_context_condition(disease_context),
      " AND "
    )
  end

  defp where_conditions({:magnitude, value}, location_context, disease_context) do
    Enum.join(
      [
        "location_context = #{location_context}",
        "location_id >= #{value}",
        "location_id < #{value * 10 - 1}"
      ]
      |> maybe_add_disease_context_condition(disease_context),
      " AND "
    )
  end

  defp maybe_add_disease_context_condition(conditions, disease_context) do
    if is_nil(disease_context) do
      conditions
    else
      ["disease_context = #{disease_context}"] ++ conditions
    end
  end

  defp create_unique_index(table_name) do
    create unique_index(
             "#{table_name}_yearly_cases",
             [:location_context, :location_id, :year],
             name: "#{table_name}_yearly_cases_unique_index"
           )
  end
end
