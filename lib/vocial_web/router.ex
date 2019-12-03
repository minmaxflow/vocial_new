defmodule VocialWeb.Router do
  use VocialWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug VocialWeb.VerifyApiKey
  end

  scope "/", VocialWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/polls", PollController, [:index, :new, :create, :show]
    get "/options/:id/vote", PollController, :vote

    resources "/users", UserController, [:new, :create, :show]
    post "/users/:id/generate_api_key", UserController, :generate_api_key

    get "/login", SessionController, :new
    post "/sessions", SessionController, :create
    get "/logout", SessionController, :delete
  end

  scope "/auth", VocialWeb do
    pipe_through :browser

    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :callback
  end

  scope "/api", VocialWeb.Api do
    pipe_through :api

    resources "/polls", PollController, only: [:index, :show]
  end
end
