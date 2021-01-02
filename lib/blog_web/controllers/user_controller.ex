defmodule BlogWeb.UserController do
  use BlogWeb, :controller

  alias Blog.Guardian

  alias Blog.Users
  alias Blog.Users.User

  action_fallback BlogWeb.FallbackController

  def index(conn, _attrs) do
    with %User{} <- Guardian.Plug.current_resource(conn),
         users <- Users.list_users() do
      conn
      |> put_status(:ok)
      |> put_resp_header("location", Routes.user_path(conn, :index, users))
      |> render("index.json", users: users)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("jwt.json", token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    with %User{} <- Guardian.Plug.current_resource(conn),
         {:ok, %User{} = user} <- Users.get_user(id) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _attrs) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, %User{}} <- Users.delete_user(user) do
      conn
      |> resp(:no_content, "User deleted")
      |> send_resp()
    end
  end
end
