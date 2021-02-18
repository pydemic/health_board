defmodule HealthBoardWeb.DashboardLive.Components.Fragments.MaybeLink do
  use Surface.Component
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop content, :any, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="inline-flex">
      <span :if={{ is_binary(@content) }}>
        {{ @content }}
      </span>

      <a :if={{ is_tuple(@content) }} href={{ to_route(@socket, @params, elem(@content, 1)) }} target="_blank" class="hover:underline focus:outline-none focus:underline" >
        {{ elem(@content, 0) }}
      </a>
    </div>
    """
  end

  defp to_route(socket, params, content_params) do
    Router.Helpers.dashboard_path(socket, :index, Map.merge(params, content_params))
  end
end
