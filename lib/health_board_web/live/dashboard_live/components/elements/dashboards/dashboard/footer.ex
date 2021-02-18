defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Footer do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop other_dashboards, :list, required: true

  prop params, :map, required: true

  prop organizations, :list, default: [{"https://www.paho.org/pt/brasil", "/images/logo_paho_white.svg"}]
  prop version, :string, default: "0.0.1"

  prop dark_mode, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <footer class="lg:px-10 sm:px-6 px-4 w-full divide-y divide-hb-ba dark:divide-hb-ba-dark bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
      <div class="py-5 grid md:grid-cols-3 grid-cols-1 place-items-stretch">
        <div>
          <div class="py-1 px-2 mb-6 md:text-left text-center font-bold">Painéis</div>

          <div class="text-sm">
            <span class="py-1 px-2 rounded-full bg-hb-ba dark:bg-hb-ba-dark text-hb-aa dark:text-hb-aa-dark">
              {{ @name }}
            </span>

            <div :for={{ dashboard <- @other_dashboards }} class="block my-3">
              <a href={{ to_route(@socket, @params, dashboard.id) }} class="py-1 px-2 rounded-full hover:bg-hb-ca dark:hover:bg-hb-ca-dark focus:outline-none focus:bg-hb-ca dark:focus:bg-hb-ca-dark">
                {{ dashboard.name }}
              </a>
            </div>
          </div>
        </div>

        <div class="md:col-span-2">
          <div class="py-1 px-2 mb-6 md:text-left text-center font-bold">Colaboração</div>

          <div class="grid md:grid-cols-2 grid-cols-1 place-items-stretch gap-4">
            <a :for={{ {link, logo} <- @organizations }} href={{ link }} target="_blank" class="m-auto max-w-lg">
              <img src={{ HealthBoardWeb.Router.Helpers.static_path(@socket, logo_path(@dark_mode, logo))}} />
            </a>
          </div>
        </div>
      </div>
      <div class="py-5 flex justify-between items-center text-xs text-center">
        <a href="mailto:changeme@paho.com.br" class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
          <Icons.At svg_class="w-5 h-5" />
        </a>

        <span class="flex-grow">
          <p>Escritório Regional para as Américas da Organização Mundial da Saúde</p>
          <p>© Organização Pan-Americana da Saúde. Todos os direitos reservados.</p>
        </span>

        <span class="m-2">
          v{{ @version }}
        </span>

        <a href="https://github.com/pydemic/health_board" target="_blank" class="hover:text-hb-ca dark:hover:text-hb-ca-dark focus:outline-none focus:text-hb-ca dark:focus:text-hb-ca-dark">
          <Icons.Github svg_class="w-5 h-5" />
        </a>
      </div>
    </footer>
    """
  end

  defp logo_path(dark_mode?, path) do
    if dark_mode? do
      ext = Path.extname(path)
      dir = Path.dirname(path)

      dir
      |> Path.join(Path.basename(path, ext))
      |> Path.join("dark#{ext}")
    else
      path
    end
  end

  defp to_route(socket, params, id) do
    Router.Helpers.dashboard_path(socket, :index, Map.put(params, "id", id))
  end
end
