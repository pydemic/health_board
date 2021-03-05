defmodule HealthBoardWeb.Router do
  use HealthBoardWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :live_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HealthBoardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :health_board_basic_auth, env: :dashboard_password
  end

  scope "/" do
    pipe_through :live_browser

    live "/:id", HealthBoardWeb.DashboardLive, :index
    live "/", HealthBoardWeb.DashboardLive, :index
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    get "/alive", HealthBoardWeb.AliveController, :list
  end

  pipeline :live_dashboard_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :health_board_basic_auth, env: :system_password
  end

  scope "/admin/system" do
    pipe_through :live_dashboard_browser

    live_dashboard "/", ecto_repos: [HealthBoard.Repo]
  end

  defp health_board_basic_auth(conn, env: env) do
    password =
      :health_board
      |> Application.get_env(:router, [])
      |> Keyword.get(env, "Pass@123")

    Plug.BasicAuth.basic_auth(conn, username: "admin", password: password)
  end
end
