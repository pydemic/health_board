defmodule HealthBoardWeb.DashboardLive.Components.NoDashboard do
  use Surface.Component

  alias Phoenix.LiveView

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="min-h-screen justify-center items-center flex bg-indigo-700 dark:bg-indigo-900">
      <div class="text-center shadow-2xl py-20 px-10 mx-auto rounded-3xl bg-white dark:bg-gray-800">
        <h2 class="text-indigo-500 dark:text-gray-400 mb-5 text-2xl font-bold">Painel não encontrado</h2>
        <p class="text-gray-600 dark:text-gray-500 text-sm">Por favor, verifique o endereço e tente novamente.</p>
      </div>
    </div>
    """
  end
end
