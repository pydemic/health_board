defmodule HealthBoardWeb.DashboardLive.Components.Fragments.MaybeLink do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop value, :any, required: true
  prop link, :any, default: nil
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="inline-flex">
      <Otherwise condition={{ @link }}>
        <a href={{ link(@socket, @params, @link) }} target="_blank" class="hover:underline focus:outline-none focus:underline" >
          {{ @value }}
        </a>

        <template slot="otherwise">
          <span>{{ @value }}</span>
        </template>
      </Otherwise>
    </div>
    """
  end

  defp link(socket, params, link_data) do
    if is_map(link_data) do
      Router.Helpers.dashboard_path(socket, :index, Map.merge(params, link_data))
    else
      link_data
    end
  end
end
