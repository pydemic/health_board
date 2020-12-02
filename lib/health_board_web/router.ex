defmodule HealthBoardWeb.Router do
  use HealthBoardWeb, :router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :live_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HealthBoardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :live_browser

    live "/", HealthBoardWeb.HomeLive, :index
    live "/:dashboard_id", HealthBoardWeb.DashboardLive, :index
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    get "/alive", HealthBoardWeb.AliveController, :list
    get "/geojson/:path", HealthBoardWeb.GeoJSONController, :show
  end

  pipeline :live_dashboard_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :basic_auth, username: "admin", password: "pah02020"
  end

  scope "/admin/system" do
    pipe_through :live_dashboard_browser

    live_dashboard "/", ecto_repos: [HealthBoard.Repo]
  end
end
