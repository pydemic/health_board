defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.RangesModal do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Tag
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop ranges, :list, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 z-1000 bg-black bg-opacity-75">
      <div class="mt-10 h-5/6 w-11/12 flex items-center mx-auto">
        <div class="flex flex-col p-5 mx-auto max-h-full rounded-lg bg-hb-a dark:bg-hb-a-dark">
          <div class="sm:flex sm:items-start max-h-full">
            <div class="flex items-center justify-center flex-shrink-0 sm:mx-0 mx-auto sm:h-10 h-12 sm:w-10 w-12 rounded-full bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
              <Tag />
            </div>

            <div class="sm:mt-2 mt-3 sm:ml-4 sm:text-left text-center max-h-full">
              <h3 class="text-lg leading-6 font-medium">{{ @name }}: Legenda</h3>
            </div>
          </div>

          <div class="px-5 mt-3 flex-shrink overflow-y-auto">
            <div class="my-5 p-5 grid gap-4 border rounded-lg border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
              <div :for={{ %{from: from, to: to, group: group} <- @ranges }}>
                <div class={{ "inline-flex", "align-middle", "h-5", "w-5", "rounded-lg", "bg-hb-choropleth-#{group}", "dark:bg-hb-choropleth-#{group}-dark" }}></div>
                <span class="ml-2 align-middle">{{ humanize_range(from, to) }}</span>
              </div>
            </div>
          </div>

          <div class="border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
            <div class="sm:flex sm:flex-row-reverse sm:px-0 px-4 py-3">
              <span class="flex mt-5 sm:w-auto w-full rounded-md">
                <button type="button" :on-click="hide" class="px-4 py-2 inline-flex justify-center w-full text-sm text-opacity-50 rounded-md border border-opacity-50 text-hb-b dark:text-hb-b-dark border-hb-b dark:border-hb-b-dark hover:text-hb-ca dark:hover:text-hb-aa hover:border-hb-ca dark:hover:border-hb-aa focus:outline-none focus:text-hb-ca dark:focus:text-hb-aa focus:border-hb-ca dark:focus:border-hb-aa dark:hover:text-opacity-100 dark:hover:border-opacity-100 dark:focus:text-opacity-100 dark:focus:border-opacity-100">
                  Fechar
                </button>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("hide", _value, socket) do
    Modals.hide_ranges()

    {:noreply, socket}
  end

  defp humanize_range(nil, _to), do: Humanize.number(0)
  defp humanize_range(from, nil), do: "#{Humanize.number(from)} ou mais"
  defp humanize_range(from, to), do: "#{Humanize.number(from)} ~ #{Humanize.number(to)}"
end
