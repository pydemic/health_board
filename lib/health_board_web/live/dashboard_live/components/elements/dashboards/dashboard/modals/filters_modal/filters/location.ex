defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.Filters.Location do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Search, as: SearchIcon
  alias Phoenix.LiveView
  alias Surface.Components.Form

  prop changes, :map, required: true
  prop filter, :map, required: true

  data location_name, :string, default: ""
  data search_results, :list, default: []

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <Form :if={{ @filter.disabled != true }} for={{ :location }} change="search">
        <div>
          <label for={{ :location_name }} class="block ml-3">Pesquisar</label>

          <div class="relative inline-flex">
            <span class="absolute inset-y-0 right-0 ml-2 flex items-center pr-2 pointer-events-none">
              <SearchIcon svg_class="w-5 h-5 text-hb-aa" />
            </span>

            <input :on-debounce="500" type="text" name="location" placeholder="Ex: Brasil" value={{ @location_name }} autocomplete="off" class="pl-3 pr-6 border rounded-full border-opacity-20 hover:border-opacity-100 border-hb-aa bg-hb-a dark:bg-hb-a-dark focus:outline-none focus:border-opacity-100 appearance-none" />
          </div>

          <div>
            <div :for={{ result <- @search_results }} :on-click="select" phx-value-result={{ result }} class="inline-flex items-center px-2 py-1 mr-2 text-xs rounded-full cursor-pointer bg-hb-aa dark:bg-hb-aa-dark bg-opacity-40 text-hb-aa-dark dark:text-hb-b-dark hover:bg-hb-c dark:hover:bg-hb-c-dark focus:outline-none focus:bg-hb-c dark:focus:bg-hb-c-dark">
              {{ result }}
            </div>
          </div>
        </div>
      </Form>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("search", %{"location" => location_name}, socket) do
    {:noreply,
     LiveView.assign(socket,
       search_results: search(socket.assigns.filter.options.locations, location_name),
       location_name: location_name
     )}
  end

  def handle_event("select", %{"result" => location_name}, %{assigns: %{changes: changes, filter: filter}} = socket) do
    case Enum.find(filter.options.locations, &(elem(&1, 0) == location_name)) do
      {_name, {_query_name, location_id}} ->
        if location_id != filter.value.id do
          FiltersModal.update_changes(Map.put(changes, "location", location_id))
        else
          FiltersModal.update_changes(Map.delete(changes, "location"))
        end

        {:noreply, LiveView.assign(socket, location_name: location_name, search_results: [])}

      _result ->
        {:noreply, socket}
    end
  end

  defp search(locations, location_name) do
    location_name = String.trim(location_name)

    if String.length(location_name) > 1 do
      location_name =
        location_name
        |> String.downcase()
        |> :unicode.characters_to_nfd_binary()
        |> String.replace(~r/[^a-z0-9\s]/u, "")

      locations
      |> Enum.split_with(&String.starts_with?(elem(elem(&1, 1), 0), location_name))
      |> maybe_filter_by_contains(location_name)
      |> Enum.map(&elem(&1, 0))
    else
      []
    end
  end

  defp maybe_filter_by_contains({result, locations}, location_name) do
    result_length = length(result)

    if result_length > 15 do
      Enum.take(result, 15)
    else
      contains_result =
        locations
        |> Enum.filter(&String.contains?(elem(elem(&1, 1), 0), location_name))
        |> Enum.take(15 - result_length)

      result ++ contains_result
    end
  end
end
