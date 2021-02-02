defmodule HealthBoardWeb.DashboardLive.Components.NoDashboard do
  use Surface.Component

  alias Phoenix.LiveView

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="min-h-screen justify-center items-center flex bg-indigo-700">
      <div class="text-gray-600 text-center shadow-lg py-20 px-10 mx-auto rounded-3xl bg-white">
        <h2 class="text-indigo-500 mb-5 text-2xl font-bold">Painel não encontrado</h2>
        <p class="text-sm">Por favor, verifique o endereço e tente novamente.</p>
      </div>
    </div>
    """
  end
end
