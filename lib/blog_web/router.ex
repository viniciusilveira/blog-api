defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Blog.Guardian.AuthPipeline
  end

  scope "/api", BlogWeb do
    pipe_through :api
    post "/users", UserController, :create

    post "/login", SessionController, :create
  end

  scope "/api", BlogWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    delete "/users/me", UserController, :delete

    get "/post", PostController, :index
    get "/post/search", PostController, :search
    post "/post", PostController, :create
    get "/post/:id", PostController, :show
    put "/post/:id", PostController, :update
    delete "/post/:id", PostController, :delete
  end
end
