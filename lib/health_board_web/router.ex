defmodule HealthBoardWeb.Router do
  use HealthBoardWeb, :router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  # pipeline :live_browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_live_flash
  #   plug :put_root_layout, {HealthBoardWeb.LayoutView, :root}
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  # scope "/" do
  #   pipe_through :live_browser
  # end

  pipeline :live_dashboard_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :basic_auth, username: "admin", password: "pah02020"
  end

  scope "/" do
    pipe_through :live_dashboard_browser

    live_dashboard "/", ecto_repos: [HealthBoard.Repo]
  end
end
