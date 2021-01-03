defmodule HealthBoardWeb.DashboardLive.Components.Card do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{CardBodyText, CardHeaderTitle}
  alias Phoenix.LiveView

  prop body_class, :string

  prop border_color, :atom, values: [:success, :warning, :danger, :disabled]

  prop width_l, :integer, default: 4
  prop width_m, :integer, default: 2

  prop title, :string
  prop link, :string

  prop content, :string
  prop anchor, :string

  slot header, props: [:border_color, :title]
  slot body, props: [:content, :class]
  slot footer, props: [:border_color]
  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div
      id={{ @anchor }}
      class={{
        "uk-width-1-#{@width_l}@l",
        "uk-width-1-#{@width_m}@m"
      }}
    >
      <div class={{
        "uk-card",
        "uk-card-hover",
        "uk-card-default",
        "hb-border": @border_color,
        "hb-border-#{@border_color}": @border_color
      }}>
        <slot
          name="header"
          :props={{ border_color: @border_color, title: @title}}
        >
          <CardHeaderTitle border_color={{ @border_color }} link={{ @link }} title={{ @title }}/>
        </slot>

        <slot
          name="body"
          :props={{ content: @content, class: @body_class }}
        >
          <CardBodyText content={{ @content }} class={{ @body_class }} />
        </slot>

        <slot
          name="footer"
          class={{ "#{@match_class}": @match and @match_in == :footer }}
          :props={{ border_color: @border_color }}
        />

        <slot/>
      </div>
    </div>
    """
  end
end
