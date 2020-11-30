defmodule HealthBoardWeb.DashboardLive.TableCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    headers = assigns.payload.data.headers
    lines = assigns.payload.result

    ~L"""
    <div class="<%= root_class @options %>">
      <div class="uk-card uk-card-hover uk-card-default">
        <div class="uk-card-header">
          <h3 class="uk-card-title"><%= @payload.card.name %></h3>
        </div>

        <div class="uk-card-body hb-card-body uk-overflow-auto">
          <table class="uk-table uk-table-small uk-table-middle uk-text-small hb-table">
            <thead>
              <tr>
                <th class="hb-table-empty"></th>
                <%= for header <- headers do %>
                  <th class="hb-table-header uk-text-emphasis">
                    <div><span><%= header %></span></div>
                  </th>
                <% end %>
              </tr>
            </thead>
            <tbody>
              <%= for %{name: name, cells: cells} <- lines do %>
                <tr>
                  <td class="uk-text-right uk-text-emphasis uk-text-nowrap"><%= name %></td>
                  <%= for %{value: value, color: %{color: color}} <- cells do %>
                    <td class="hb-table-item uk-text-center uk-text-secondary hb-table-quartile-<%= color %>">
                      <%= if color != "0" do %>
                      <%= value %>
                      <% end %>
                    </td>
                  <% end %>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <div class="uk-card-footer">
          <div class="uk-grid uk-grid-small uk-grid-match">
            <div class="uk-width-1-5@m">
              <code class="hb-table-label hb-table-quartile-0 uk-text-center uk-text-secondary">
                0
              </code>
            </div>

            <div class="uk-width-1-5@m">
              <code class="hb-table-label hb-table-quartile-1 uk-text-center uk-text-secondary">
                1%-25%
              </code>
            </div>

            <div class="uk-width-1-5@m">
              <code class="hb-table-label hb-table-quartile-2 uk-text-center uk-text-secondary">
                26%-50%
              </code>
            </div>

            <div class="uk-width-1-5@m">
              <code class="hb-table-label hb-table-quartile-3 uk-text-center uk-text-secondary">
                51%-75%
              </code>
            </div>

            <div class="uk-width-1-5@m">
              <code class="hb-table-label hb-table-quartile-4 uk-text-center uk-text-secondary">
                76%-100%
              </code>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp root_class(options) do
    []
    |> add_width(options[:width_l] || 2, "l")
    |> add_width(options[:width_m] || 1, "m")
    |> Enum.join(" ")
  end

  defp add_width(class, value, scale), do: ["uk-width-1-#{value}@#{scale}"] ++ class
end
