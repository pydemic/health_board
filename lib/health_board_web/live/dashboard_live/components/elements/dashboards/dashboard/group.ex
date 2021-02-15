defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Group do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.DynamicElement
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias Phoenix.LiveView

  prop group, :any

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Otherwise condition={{ is_nil(@group) }}>
      <div class="min-h-screen justify-center items-center flex">
        <div class="text-gray-600 text-center shadow-2xl py-20 px-10 mx-auto rounded-3xl bg-white">
          <h2 class="text-indigo-500 mb-5 text-2xl font-bold">Grupo não encontrado</h2>
          <p class="text-sm">Por favor, selecione o grupo adequado no menu acima.</p>
        </div>
      </div>

      <template slot="otherwise">
        <DynamicElement element={{ @group.child }} />
      </template>
    </Otherwise>
    """
  end
end
