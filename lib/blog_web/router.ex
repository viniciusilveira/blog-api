defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Blog.Guardian.AuthPipeline
  end

  scope "/", BlogWeb do
    pipe_through :api
    post "/user", UserController, :create

    post "/login", SessionController, :create
  end

  scope "/", BlogWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/user", UserController, :index
    get "/user/:id", UserController, :show
    delete "/user/me", UserController, :delete

    get "/post", PostController, :index
    get "/post/search", PostController, :search
    post "/post", PostController, :create
    get "/post/:id", PostController, :show
    put "/post/:id", PostController, :update
    delete "/post/:id", PostController, :delete
  end
end
