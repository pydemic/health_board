defmodule HealthBoardWeb.DashboardLive.CardComponent do
  use Phoenix.LiveComponent

  alias HealthBoardWeb.DashboardLive.Renderings
  alias Phoenix.LiveView

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    options = assigns[:options] || []

    ~L"""
    <div class="<%= root_class options %>">
      <div class="uk-card uk-card-hover uk-card-default uk-visible-toggle" tabindex="-1">
        <%= Renderings.maybe_render assigns, :title, &title(&1, options) %>
        <%= Renderings.maybe_render assigns, :body, &body(&1, options) %>
        <%= Renderings.maybe_render assigns, :footer, &footer(&1, options) %>
      </div>

      <%= Renderings.maybe_render assigns, :extras, &extras/1 %>
    </div>
    """
  end

  defp title(assigns, options) do
    ~L"""
    <div class="<%= title_class options %>">
      <h3 class="<%= title_text_class options %>">
        <%= @title %>
      </h3>
    </div>
    """
  end

  defp title_class(options) do
    ["uk-card-header"]
    |> Kernel.++(options[:title_class] || [])
    |> Enum.join(" ")
  end

  defp title_text_class(options) do
    ["uk-card-title"]
    |> Kernel.++(options[:title_text_class] || [])
    |> Enum.join(" ")
  end

  defp body(assigns, options) do
    ~L"""
    <div <%= body_id options %> class="<%= body_class options %>" <%= body_tags options %>>
      <%= @body %>
    </div>
    """
  end

  defp body_class(options) do
    ["uk-card-body", options[:matcher] || "hb-match"]
    |> Kernel.++(options[:body_class] || [])
    |> Enum.join(" ")
  end

  defp body_id(options) do
    case options[:body_id] do
      nil -> ""
      id -> "id=#{id}"
    end
  end

  defp body_tags(options) do
    Enum.join(options[:body_tags] || [], " ")
  end

  defp footer(assigns, options) do
    ~L"""
    <div class="<%= footer_class options %>" phx-update="ignore">
      <%= @footer %>
    </div>
    """
  end

  defp footer_class(options) do
    ["uk-card-footer"]
    |> Kernel.++(options[:footer_class] || [])
    |> Enum.join(" ")
  end

  defp extras(assigns) do
    ~L"<%= @extras %>"
  end

  defp root_class(options) do
    []
    |> add_width(options[:width_l] || 4, "l")
    |> add_width(options[:width_m] || 2, "m")
    |> Enum.join(" ")
  end

  defp add_width(class, value, scale), do: ["uk-width-1-#{value}@#{scale}"] ++ class
end
