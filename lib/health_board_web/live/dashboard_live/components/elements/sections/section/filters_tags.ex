defmodule HealthBoardWeb.DashboardLive.Components.Section.FiltersTags do
  use Surface.LiveComponent
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop filters, :list, required: true
  prop params, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <button :for={{ filter <- @filters }} :on-click="show_filters" title={{ "Ver filtros de #{@name}" }} class="inline-flex items-center px-2 py-1 mr-2 text-xs rounded-full cursor-pointer bg-hb-aa dark:bg-hb-aa-dark bg-opacity-40 text-hb-aa-dark dark:text-hb-b-dark hover:bg-hb-c dark:hover:bg-hb-c-dark focus:outline-none focus:bg-hb-c dark:focus:bg-hb-c-dark">
        <span class="font-bold">
          {{ filter.name }}:
        </span>

        <span class="ml-2">
          {{ value(@params, filter) }}
        </span>
      </button>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("show_filters", _value, %{assigns: assigns} = socket) do
    Modals.show_filters(assigns.name, assigns.filters)

    {:noreply, socket}
  end

  defp value(params, filter) do
    params
    |> Enum.reduce(%{}, &parse_component_param/2)
    |> maybe_transform_value(filter)
  end

  defp maybe_transform_value(params, filter) do
    case Map.fetch(params, filter.sid) do
      {:ok, transform} -> maybe_transform(transform, filter)
      :error -> filter.verbose_value
    end
  end

  defp maybe_transform(%{"verbose_name" => %{"minimum_parent_group" => parent_group}}, %{sid: "location"} = filter) do
    group = Locations.group(parent_group)

    case Enum.find(filter.value.parents, &(&1.parent_group == group)) do
      %{parent: parent} -> Humanize.location(parent)
      _result -> filter.verbose_value
    end
  rescue
    _error -> filter.verbose_value
  end

  defp maybe_transform(_transform, filter), do: filter.verbose_value

  defp parse_component_param({key, value}, map) do
    if String.starts_with?(key, "filter__") do
      keys = key |> String.replace("filter__", "") |> String.split("__")

      put_in(map, Enum.map(keys, &Access.key(&1, %{})), value)
    else
      map
    end
  end
end
