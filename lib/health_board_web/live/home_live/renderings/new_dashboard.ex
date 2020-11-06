defmodule HealthBoardWeb.HomeLive.Renderings.NewDashboard do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    show? = Map.get(assigns, :show_new_dashboard, true)

    ~L"""
    <div class="uk-section uk-section-xsmall">
      <%= title assigns, show? %>
      <%= if show? do %>
        <%= form assigns %>
      <% end %>
    </div>
    """
  end

  defp title(assigns, show?) do
    icon_class = if show?, do: "gg-math-minus", else: "gg-math-plus"

    ~L"""
    <h2
      class="uk-heading-divider uk-margin-left uk-margin-right hb-va-center hb-clickable"
      phx-click="toggle_new_dashboard"
    >
      Novo painel <i class="<%= icon_class %> hb-right"></i>
    </h2>
    """
  end

  defp form(assigns) do
    ~L"""
    <form class="uk-form-stacked uk-margin-left uk-margin-right">
      <div class="uk-margin">
        <label class="uk-form-label" for="name">Nome</label>
        <div class="uk-form-controls">
          <input class="uk-input" id="name" type="text">
        </div>
      </div>

      <div class="uk-margin">
        <label class="uk-form-label" for="description">Descrição</label>
        <div class="uk-form-controls">
          <textarea id="description" class="uk-textarea" rows="5"></textarea>
        </div>
      </div>

      <div class="uk-margin">
        <label class="uk-form-label" for="description">Indicadores</label>
        <div class="uk-form-controls">
          <label>
            <input class="uk-checkbox" type="checkbox" name="indicators">
            Indicador 1
          </label>

          <label>
            <input class="uk-checkbox" type="checkbox" name="indicators">
            Indicador 2
          </label>
        </div>
      </div>

      <div class="uk-margin">
        <label class="uk-form-label" for="description">Filtros</label>
        <div class="uk-form-controls">
          <label>
            <input class="uk-checkbox" type="checkbox" name="indicators">
            Filtro 1
          </label>

          <label>
            <input class="uk-checkbox" type="checkbox" name="indicators">
            Filtro 2
          </label>
        </div>
      </div>

      <submit class="uk-button uk-button-primary uk-align-right">Criar painel</submit>
    </form>
    """
  end
end
