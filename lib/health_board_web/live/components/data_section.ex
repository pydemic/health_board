defmodule HealthBoardWeb.LiveComponents.DataSection do
  use Surface.LiveComponent

  alias HealthBoardWeb.LiveComponents.{Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  data data, :map, default: %{}

  slot default, props: [:data]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />

      <slot :props={{ data: @data }} />
    </Section>
    """
  end

  @spec fetch(String.t() | atom, map) :: any
  def fetch(id, data) do
    send_update(__MODULE__, id: id, data: data)
  end
end
