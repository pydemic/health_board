defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Cooldown do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias Phoenix.LiveView

  prop wrapper_class, :css_class
  prop message, :string, default: "Aguarde um instante"

  data last_trigger, :any, default: nil
  data can_trigger, :boolean, default: true

  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Otherwise condition={{ @can_trigger }}>
      <slot />

      <template slot="otherwise">
        <div x-data="{ countdown: 15 }" x-init="window.setInterval(() => { if (countdown > 0) countdown -= 1 }, 1000)" class={{ @wrapper_class }} >
          <span x-show="countdown > 0" x-text="countdown" title={{ @message }}></span>
        </div>
      </template>
    </Otherwise>
    """
  end

  @spec trigger(pid, String.t() | atom) :: any
  def trigger(pid \\ self(), id) do
    LiveView.send_update(pid, __MODULE__, id: id, can_trigger: false, last_trigger: DateTime.utc_now())
    LiveView.send_update_after(pid, __MODULE__, [id: id, can_trigger: true, last_trigger: nil], 15_000)
  end
end
