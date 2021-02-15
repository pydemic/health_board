defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals do
  use Surface.LiveComponent
  alias __MODULE__.{FiltersModal, IndicatorsModal, SourcesModal}
  alias Phoenix.LiveView

  @id :modals

  prop params, :map, required: true

  data name, :string, default: "Painel"

  data filters, :list, default: []
  data indicators, :list, default: []
  data sources, :list, default: []

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ Enum.any?(@indicators) or Enum.any?(@filters) or Enum.any?(@sources) }}>
      <FiltersModal :if={{ Enum.any?(@filters) }} id={{ :filters_modal }} name={{ @name }} filters={{ @filters }} params={{ @params }} />
      <IndicatorsModal :if={{ Enum.any?(@indicators) }} id={{ :indicators_modal }} name={{ @name }} indicators={{ @indicators }} />
      <SourcesModal :if={{ Enum.any?(@sources) }} id={{ :sources_modal }} name={{ @name }} sources={{ @sources }} />
    </div>
    """
  end

  @spec show_filters(pid, String.t(), list(map)) :: any
  def show_filters(pid \\ self(), name, filters), do: show(pid, name, :filters, filters)

  @spec hide_filters(pid) :: any
  def hide_filters(pid \\ self()), do: hide(pid, :filters)

  @spec show_indicators(pid, String.t(), list(map)) :: any
  def show_indicators(pid \\ self(), name, indicators), do: show(pid, name, :indicators, indicators)

  @spec hide_indicators(pid) :: any
  def hide_indicators(pid \\ self()), do: hide(pid, :indicators)

  @spec show_sources(pid, String.t(), list(map)) :: any
  def show_sources(pid \\ self(), name, sources), do: show(pid, name, :sources, sources)

  @spec hide_sources(pid) :: any
  def hide_sources(pid \\ self()), do: hide(pid, :sources)

  defp show(pid, name, data_key, data_list) do
    send_update(pid, __MODULE__, [{:id, @id}, {:name, name}, {data_key, data_list}])
  end

  defp hide(pid, data_key) do
    send_update(pid, __MODULE__, [{:id, @id}, {:name, "Painel"}, {data_key, []}])
  end
end
