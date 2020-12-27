defmodule BlogWeb.SessionController do
  use BlogWeb, :controller

  alias Blog.Guardian
  alias Blog.Helper
  alias Blog.Users
  alias Blog.Users.User

  action_fallback BlogWeb.FallbackController

  def create(conn, attrs) do
    with {:ok, %User{} = user} <- Users.authenticate(Helper.atomize(attrs)),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_view(BlogWeb.UserView)
      |> render("jwt.json", token: token)
    end
  end
end
