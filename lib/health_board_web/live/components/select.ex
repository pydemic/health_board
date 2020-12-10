defmodule HealthBoardWeb.LiveComponents.Select do
  use Surface.Component

  alias Phoenix.LiveView

  prop field, :atom, required: true
  prop name, :string, required: true
  prop options, :list, required: true
  prop selected, :any

  prop width_l, :integer, default: 1
  prop width_m, :integer, default: 1

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-width-1-#{@width_l}@l": @width_l, "uk-width-1-#{@width_m}@m": @width_m }}>
      <label class="uk-form-label uk-text-left" for={{ @field }}>
        {{ @name }}
      </label>

      <div class="uk-form-controls">
        <select class="uk-select" name={{ @field }}>
          <option
            :for={{ {name, value} <- @options }}
            value={{ value || "nil" }}
            selected={{ value == @selected }}
          >
            {{ name }}
          </option>
        </select>
      </div>
    </div>
    """
  end
end
