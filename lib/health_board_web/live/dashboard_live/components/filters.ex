defmodule HealthBoardWeb.DashboardLive.Components.Filters do
  use Surface.LiveComponent

  alias HealthBoardWeb.DashboardLive.Components.{DatePicker, Grid, Section, SectionHeader, Select}
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
          <div class="uk-width-1-5@l">
            <h4>Data</h4>

            <Grid>
              <DatePicker field={{ :date }} name={{ "Data" }} width_l={{ 1 }} width_m={{ 1 }} />
            </Grid>
          </div>

          <div class="uk-width-4-5@l">
            <h4>Localidade</h4>

            <Grid>
              <Select field={{ :region }} name={{ "Região" }} selected={{ @filters[:region] }} options={{ @options[:region] || [] }} width_l={{ 4 }} width_m={{ 1 }} />
              <Select field={{ :state }} name={{ "Estado" }} selected={{ @filters[:state] }} options={{ @options[:state] || [] }} width_l={{ 4 }} width_m={{ 1 }} />
              <Select field={{ :health_region }} name={{ "Regional de saúde" }} selected={{ @filters[:health_region] }} options={{ @options[:health_region] || [] }} width_l={{ 4 }} width_m={{ 1 }} />
              <Select field={{ :city }} name={{ "Município" }} selected={{ @filters[:city] }} options={{ @options[:city] || [] }} width_l={{ 4 }} width_m={{ 1 }} />
            </Grid>
          </div>
        </Grid>
      </form>
    </Section>
    """
  end
end
