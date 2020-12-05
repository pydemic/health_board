defmodule HealthBoardWeb.LiveComponents.Card do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{CardBodyText, CardHeaderTitle}
  alias Phoenix.LiveView

  @doc "Additional class for the card body div"
  prop body_class, :string

  @doc "The card border color"
  prop border_color, :atom, values: [:success, :warning, :danger, :disabled]

  @doc "The width of the card on large screens"
  prop width_l, :integer, default: 4

  @doc "The width of the card on average-size screens"
  prop width_m, :integer, default: 2

  @doc "The title of the card. Will be used if header slot is not defined"
  prop title, :string

  @doc "A link to be used at the title. Will be used if header slot is not defined"
  prop link, :string

  @doc "The concent of the card. Will be used if body slot is not defined"
  prop content, :string

  @doc "The header of the card"
  slot header, props: [:border_color, :title]

  @doc "The body of the card"
  slot body, props: [:content, :class]

  @doc "The footer of the card"
  slot footer, props: [:border_color]

  @doc "Extra slot for additional elements"
  slot default

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{
      "uk-width-1-#{@width_l}@l",
      "uk-width-1-#{@width_m}@m"
    }}>
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
