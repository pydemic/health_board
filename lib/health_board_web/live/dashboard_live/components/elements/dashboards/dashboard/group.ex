defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Group do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.DynamicElement
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias Phoenix.LiveView

  prop group, :any

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Otherwise condition={{ is_nil(@group) }} wrapper_class="flex-grow" extra_true_class="flex justify-center items-center">
      <div class="py-20 px-10 mx-auto rounded-3xl text-center bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:hb-ba-dark">
        <h2 class="mb-5 text-2xl font-bold">Grupo não encontrado</h2>
        <p class="text-sm">Por favor, selecione o grupo adequado no menu acima.</p>
      </div>

      <template slot="otherwise">
        <DynamicElement element={{ @group.child }} />
      </template>
    </Otherwise>
    """
  end
end
