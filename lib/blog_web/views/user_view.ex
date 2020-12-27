defmodule BlogWeb.UserView do
  use BlogWeb, :view
  alias BlogWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, display_name: user.display_name, email: user.email, image: user.image}
  end

  def render("jwt.json", %{token: token}), do: %{token: token}
end
