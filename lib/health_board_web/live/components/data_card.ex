defmodule HealthBoardWeb.LiveComponents.DataCard do
  use Surface.LiveComponent

  alias HealthBoardWeb.LiveComponents.{CardBodyText, CardHeaderTitle}
  alias Phoenix.LiveView

  prop body_class, :string

  prop border_color, :atom, values: [:success, :warning, :danger]

  prop width_l, :integer, default: 4
  prop width_m, :integer, default: 2

  prop title, :string
  prop link, :string

  prop content, :string

  data data, :map, default: %{}

  slot header, props: [:data, :border_color, :title]
  slot body, props: [:data, :content, :class]
  slot footer, props: [:data, :border_color]
  slot default, props: [:data]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    border_color = assigns.border_color || assigns.data[:border_color]

    ~H"""
    <div
      class={{
        "uk-width-1-#{@width_l}@l",
        "uk-width-1-#{@width_m}@m"
      }}
    >
      <div class={{
        "uk-card",
        "uk-card-hover",
        "uk-card-default",
        "hb-border": border_color,
        "hb-border-#{border_color}": border_color
      }}>
        <slot
          name="header"
          :props={{ data: @data, border_color: border_color, title: @title}}
        >
          <CardHeaderTitle border_color={{ border_color }} link={{ @link }} title={{ @title }}/>
        </slot>

        <slot
          name="body"
          :props={{ data: @data, content: @content, class: @body_class }}
        >
          <CardBodyText content={{ @content }} class={{ @body_class }} />
        </slot>

        <slot
          name="footer"
          class={{ "#{@match_class}": @match and @match_in == :footer }}
          :props={{ data: @data, border_color: border_color }}
        />

        <slot :props={{ data: @data }} />
      </div>
    </div>
    """
  end

  @spec fetch(String.t() | atom, map) :: any
  def fetch(id, data) do
    send_update(__MODULE__, id: id, data: data)
  end
end
