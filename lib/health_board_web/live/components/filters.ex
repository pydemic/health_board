defmodule HealthBoardWeb.LiveComponents.Filters do
  use Surface.LiveComponent

  alias HealthBoardWeb.LiveComponents.{DatePicker, Grid, Section, SectionHeader, Select}
  alias Phoenix.LiveView

  prop filters, :map, required: true
  prop options, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SectionHeader title={{ "Filtros "}} description={{ "Filtros do painel" }} />

      <form :on-change={{ "apply_filter", target: :live_view }}>
        <Grid>
          <div class="uk-width-1-2@l">
            <h4>Data</h4>

            <Grid>
              <DatePicker field={{ :date_date_picker }} name={{ "Data" }}  width_l={{ 3 }} width_m={{ 1 }} />
              <DatePicker field={{ :from_date_picker }} name={{ "Data inicial" }}  width_l={{ 3 }} width_m={{ 1 }} />
              <DatePicker field={{ :to_date_picker }} name={{ "Data final" }}  width_l={{ 3 }} width_m={{ 1 }} />
              <Select field={{ :year }} name={{ "Ano" }} selected={{ @filters[:year] }} options={{ @options[:year] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
              <Select field={{ :from_year }} name={{ "Ano inicial" }} selected={{ @filters[:from_year] }} options={{ @options[:from_year] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
              <Select field={{ :to_year }} name={{ "Ano final" }} selected={{ @filters[:to_year] }} options={{ @options[:to_year] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
            </Grid>
          </div>

          <div class="uk-width-1-2@l">
            <h4>Localidade</h4>

            <Grid>
              <Select field={{ :state }} name={{ "Estado" }} selected={{ @filters[:state] }} options={{ @options[:state] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
              <Select field={{ :health_region }} name={{ "Regional de saúde" }} selected={{ @filters[:health_region] }} options={{ @options[:health_region] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
              <Select field={{ :city }} name={{ "Município" }} selected={{ @filters[:city] }} options={{ @options[:city] || [] }} width_l={{ 3 }} width_m={{ 1 }} />
            </Grid>
          </div>
        </Grid>
      </form>
    </Section>
    """
  end
end
