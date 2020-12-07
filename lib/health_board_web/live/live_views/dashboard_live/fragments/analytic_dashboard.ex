defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.{History, Region, Summary}
  alias HealthBoardWeb.LiveComponents.{Card, Grid, Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    sections = assigns.dashboard.sections

    if is_map(sections) do
      ~H"""
      <Section>
        <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

        <Summary
          :if={{ false and Map.has_key?(sections, :immediate_compulsory_analytic_summary) }}
          section={{ sections[:immediate_compulsory_analytic_summary] }}
        />

        <Summary
          :if={{ false and Map.has_key?(sections, :weekly_compulsory_analytic_summary) }}
          section={{ sections[:weekly_compulsory_analytic_summary] }} />

        <History
          :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_history) }}
          section={{ sections[:immediate_compulsory_analytic_history] }}
          section_cards_ids={{[
            :country_immediate_compulsory_incidence_rate_per_year,
            :country_immediate_compulsory_death_rate_per_year,
            :state_immediate_compulsory_incidence_rate_per_year,
            :state_immediate_compulsory_death_rate_per_year,
            :city_immediate_compulsory_incidence_rate_per_year,
            :city_immediate_compulsory_death_rate_per_year,
          ]}}
        />

        <History
          :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_history) }}
          section={{ sections[:weekly_compulsory_analytic_history] }}
          section_cards_ids={{[
            :weekly_compulsory_incidence_rate_per_year,
            :weekly_compulsory_death_rate_per_year
          ]}}
        />

        <Region
          :if={{ Map.has_key?(sections, :immediate_compulsory_analytic_region) }}
          section={{ sections[:immediate_compulsory_analytic_region] }}
          section_cards_ids={{[
            :immediate_compulsory_incidence_rate_table,
            :immediate_compulsory_death_rate_table
          ]}}
        />

        <Region
          :if={{ Map.has_key?(sections, :weekly_compulsory_analytic_region) }}
          section={{ sections[:weekly_compulsory_analytic_region] }}
          section_cards_ids={{[
            :weekly_compulsory_incidence_rate_table,
            :weekly_compulsory_death_rate_table
          ]}}
        />
      </Section>
      """
    else
      title = "Carregando"
      content = "Gerando indicadores para este painel. Em instantes o painel estará pronto para visualização."

      ~H"""
      <Section>
        <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

        <Grid>
          <Card
            width_l={{ 2 }}
            width_m={{ 1 }}
            title={{ title }}
            content={{ content }}
          />
        </Grid>
      </Section>
      """
    end
  end

  #   <ControlDiagrams
  #   ::if={{   Map.has_key?(sections, :immediate_compulsory_analytic_control_diagrams) }}
  #   section={{ sections[:immediate_compulsory_analytic_control_diagrams] }}
  #   section_cards_ids={{[
  #     :accident_by_venomous_animals_incidence_rate_control_diagram,
  #     :accident_by_venomous_animals_death_rate_control_diagram,
  #     :accidental_tetanus_incidence_rate_control_diagram,
  #     :accidental_tetanus_death_rate_control_diagram,
  #     :acute_chagas_disease_incidence_rate_control_diagram,
  #     :acute_chagas_disease_death_rate_control_diagram,
  #     :acute_flaccid_paralysis_incidence_rate_control_diagram,
  #     :acute_flaccid_paralysis_death_rate_control_diagram,
  #     :anthrax_incidence_rate_control_diagram,
  #     :anthrax_death_rate_control_diagram,
  #     :arenavirus_incidence_rate_control_diagram,
  #     :arenavirus_death_rate_control_diagram,
  #     :botulism_incidence_rate_control_diagram,
  #     :botulism_death_rate_control_diagram,
  #     :brazilian_purpuric_fever_incidence_rate_control_diagram,
  #     :brazilian_purpuric_fever_death_rate_control_diagram,
  #     :chikungunya_incidence_rate_control_diagram,
  #     :chikungunya_death_rate_control_diagram,
  #     :cholera_incidence_rate_control_diagram,
  #     :cholera_death_rate_control_diagram,
  #     :congenital_rubella_syndrome_incidence_rate_control_diagram,
  #     :congenital_rubella_syndrome_death_rate_control_diagram,
  #     :coqueluche_incidence_rate_control_diagram,
  #     :coqueluche_death_rate_control_diagram,
  #     :dengue_incidence_rate_control_diagram,
  #     :dengue_death_rate_control_diagram,
  #     :diphtheria_incidence_rate_control_diagram,
  #     :diphtheria_death_rate_control_diagram,
  #     :ebola_incidence_rate_control_diagram,
  #     :ebola_death_rate_control_diagram,
  #     :extra_amazon_malaria_incidence_rate_control_diagram,
  #     :extra_amazon_malaria_death_rate_control_diagram,
  #     :hantavirus_incidence_rate_control_diagram,
  #     :hantavirus_death_rate_control_diagram,
  #     :human_rabies_incidence_rate_control_diagram,
  #     :human_rabies_death_rate_control_diagram,
  #     :lassa_incidence_rate_control_diagram,
  #     :lassa_death_rate_control_diagram,
  #     :leptospirosis_incidence_rate_control_diagram,
  #     :leptospirosis_death_rate_control_diagram,
  #     :marburg_incidence_rate_control_diagram,
  #     :marburg_death_rate_control_diagram,
  #     :measle_incidence_rate_control_diagram,
  #     :measle_death_rate_control_diagram,
  #     :meningococcal_disease_incidence_rate_control_diagram,
  #     :meningococcal_disease_death_rate_control_diagram,
  #     :neonatal_tetanus_incidence_rate_control_diagram,
  #     :neonatal_tetanus_death_rate_control_diagram,
  #     :plague_incidence_rate_control_diagram,
  #     :plague_death_rate_control_diagram,
  #     :polio_incidence_rate_control_diagram,
  #     :polio_death_rate_control_diagram,
  #     :rabies_related_animals_disease_incidence_rate_control_diagram,
  #     :rabies_related_animals_disease_death_rate_control_diagram,
  #     :rubella_incidence_rate_control_diagram,
  #     :rubella_death_rate_control_diagram,
  #     :severe_work_accident_incidence_rate_control_diagram,
  #     :severe_work_accident_death_rate_control_diagram,
  #     :smallpox_incidence_rate_control_diagram,
  #     :smallpox_death_rate_control_diagram,
  #     :spotted_fever_incidence_rate_control_diagram,
  #     :spotted_fever_death_rate_control_diagram,
  #     :suicide_incidence_rate_control_diagram,
  #     :suicide_death_rate_control_diagram,
  #     :tularemia_incidence_rate_control_diagram,
  #     :tularemia_death_rate_control_diagram,
  #     :typhoid_fever_incidence_rate_control_diagram,
  #     :typhoid_fever_death_rate_control_diagram,
  #     :varicella_incidence_rate_control_diagram,
  #     :varicella_death_rate_control_diagram,
  #     :violence_incidence_rate_control_diagram,
  #     :violence_death_rate_control_diagram,
  #     :west_nile_fever_incidence_rate_control_diagram,
  #     :west_nile_fever_death_rate_control_diagram,
  #     :yellow_fever_incidence_rate_control_diagram,
  #     :yellow_fever_death_rate_control_diagram,
  #     :zika_incidence_rate_control_diagram,
  #     :zika_death_rate_control_diagram
  #   ]}}
  # />

  # <ControlDiagrams
  #   ::if={{   Map.has_key?(sections, :weekly_compulsory_analytic_control_diagrams) }}
  #   section={{ sections[:weekly_compulsory_analytic_control_diagrams] }}
  #   section_cards_ids={{[
  #     :amazon_malaria_death_rate_control_diagram,
  #     :american_cutaneous_leishmaniasis_death_rate_control_diagram,
  #     :bio_exposure_work_accident_death_rate_control_diagram,
  #     :chronic_chagas_disease_death_rate_control_diagram,
  #     :congenital_pregnant_toxoplasmosis_death_rate_control_diagram,
  #     :exogenous_intoxication_death_rate_control_diagram,
  #     :hiv_death_rate_control_diagram,
  #     :leprosy_death_rate_control_diagram,
  #     :maternal_death_death_rate_control_diagram,
  #     :schistosomiasis_death_rate_control_diagram,
  #     :syphilis_death_rate_control_diagram,
  #     :transport_accident_death_rate_control_diagram,
  #     :tuberculosis_death_rate_control_diagram,
  #     :viral_hepatitis_death_rate_control_diagram,
  #     :visceral_leishmaniasis_death_rate_control_diagram,
  #     :amazon_malaria_incidence_rate_control_diagram,
  #     :american_cutaneous_leishmaniasis_incidence_rate_control_diagram,
  #     :bio_exposure_work_accident_incidence_rate_control_diagram,
  #     :chronic_chagas_disease_incidence_rate_control_diagram,
  #     :congenital_pregnant_toxoplasmosis_incidence_rate_control_diagram,
  #     :exogenous_intoxication_incidence_rate_control_diagram,
  #     :hiv_incidence_rate_control_diagram,
  #     :leprosy_incidence_rate_control_diagram,
  #     :maternal_death_incidence_rate_control_diagram,
  #     :schistosomiasis_incidence_rate_control_diagram,
  #     :syphilis_incidence_rate_control_diagram,
  #     :transport_accident_incidence_rate_control_diagram,
  #     :tuberculosis_incidence_rate_control_diagram,
  #     :viral_hepatitis_incidence_rate_control_diagram,
  #     :visceral_leishmaniasis_incidence_rate_control_diagram
  #   ]}}
  # />
end
