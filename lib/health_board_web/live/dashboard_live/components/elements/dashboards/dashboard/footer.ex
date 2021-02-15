defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Footer do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop other_dashboards, :list, required: true

  prop organizations, :list, default: [{"https://www.paho.org/pt/brasil", "/images/logo_paho_white.svg"}]
  prop version, :string, default: "0.0.1"

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <footer class="bg-indigo-500 p-5 divide-y divide-white">
      <div class="p-5 grid grid-cols-1 md:grid-cols-3 place-items-stretch">
        <div class="text-white">
          <div class="py-1 px-2 mb-6 text-center md:text-left">Painéis</div>

          <div class="text-sm">
            <span class="py-1 px-2 rounded-full bg-white text-indigo-500">
              {{ @name }}
            </span>

            <a :for={{ dashboard <- @other_dashboards }} href={{ dashboard.id }} class="py-1 px-2 my-3 block">
              {{ dashboard.name }}
            </a>
          </div>
        </div>

        <div class="md:col-span-2">
          <div class="py-1 px-2 mb-6 text-white text-center md:text-left">Colaboração</div>

          <div class="grid grid-cols-2 place-items-stretch gap-4">
            <a :for={{ {link, logo} <- @organizations }} href={{ link }} target="_blank" class="col-span-2 md:col-span-1 max-w-lg m-auto">
              <img src={{ HealthBoardWeb.Router.Helpers.static_path(@socket, logo)}} />
            </a>
          </div>
        </div>
      </div>
      <div class="pt-5 text-center text-xs justify-between items-center flex">
        <a href="mailto:changeme@paho.com.br"><Icons.At svg_class="w-5 h-5 text-white text-opacity-50" /></a>

        <span class="flex-grow text-white ">
          <p>Escritório Regional para as Américas da Organização Mundial da Saúde</p>
          <p>© Organização Pan-Americana da Saúde. Todos os direitos reservados.</p>
        </span>

        <span class="m-2 text-white text-opacity-50">
          v{{ @version }}
        </span>

        <a href="https://github.com/pydemic/health_board" target="_blank"><Icons.Github svg_class="w-5 h-5 text-white text-opacity-50" /></a>
      </div>
    </footer>
    """
  end
end
