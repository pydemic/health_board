defmodule HealthBoardWeb.DashboardLive.Fragments.NoDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Card, Grid, Section}
  alias Phoenix.LiveView

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    title = "Painel não encontrado"
    content = "Por favor, verifique se o endereço requisitado é um endereço para um painel válido e tente novamente."

    ~H"""
    <Section>
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
