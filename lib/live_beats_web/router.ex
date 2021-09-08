defmodule LiveBeatsWeb.Router do
  use LiveBeatsWeb, :router

  import LiveBeatsWeb.UserAuth, only: [redirect_if_user_is_authenticated: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveBeatsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveBeatsWeb do
    pipe_through :browser

    live_session :default, on_mount: {LiveBeatsWeb.UserAuth, :mount_defaults} do
      live "/test", IndexLive
      live "/", HomeLive, :index
      live "/signin", SigninLive, :index
    end
  end

  scope "/", LiveBeatsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/oauth/callbacks/:provider", OAuthCallbackController, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveBeatsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveBeatsWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end