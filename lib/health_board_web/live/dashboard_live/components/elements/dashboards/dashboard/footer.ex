defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Footer do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias Phoenix.LiveView

  prop name, :string, required: true

  prop params, :map, required: true

  prop organizations, :list, default: [{"https://www.paho.org/pt/brasil", "/images/logo_paho_white.svg"}]
  prop version, :string, default: "0.0.1"

  prop dark_mode, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <footer class="lg:px-10 sm:px-6 px-4 w-full divide-y divide-hb-ba dark:divide-hb-ba-dark bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
      <div class="py-5 grid place-items-stretch">
        <div>
          <div class="py-1 px-2 mb-6 text-center font-bold">Iniciativa</div>

          <div class="grid place-items-stretch gap-4">
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
end
