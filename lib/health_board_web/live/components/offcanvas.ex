defmodule HealthBoardWeb.LiveComponents.Offcanvas do
  use Surface.Component

  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id={{"offcanvas"}} uk-offcanvas>
    <div class={{"uk-offcanvas-bar"}}>

        <button class={{"uk-offcanvas-close"}} type="button"> X </button>

        <h3>Title</h3>

        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>

      </div>
    </div>
    """
  end
end
