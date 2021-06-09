defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Helper
  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Users.User

  action_fallback BlogWeb.FallbackController

  def search(conn, %{"q" => search_term}) do
    with %User{} <- Guardian.Plug.current_resource(conn),
         {:ok, posts} <- Posts.search_posts(search_term) do
      render(conn, "index.json", posts: posts)
    end
  end

  def index(conn, _params) do
    with %User{} <- Guardian.Plug.current_resource(conn) do
      posts = Posts.list_posts()
      render(conn, "index.json", posts: posts)
    end
  end

  def create(conn, post_params) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, %Post{} = post} <-
           post_params
           |> Map.merge(%{"user_id" => user.id})
           |> map_of_atoms()
           |> posts().create_post() do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.post_path(conn, :show, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    with %User{} <- Guardian.Plug.current_resource(conn),
         {:ok, %Post{} = post} <- Posts.get_post(id) do
      render(conn, "show_with_user.json", post: post)
    end
  end

  def update(conn, %{"id" => id} = post_params) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, %Post{} = post} <- Posts.get_post(id),
         {:ok, :success} <- is_author?(post, user.id),
         {:ok, %Post{} = post} <- Posts.update_post(post, Helper.atomize(post_params)) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %User{} = user <- Guardian.Plug.current_resource(conn),
         {:ok, %Post{} = post} <- Posts.get_post(id),
         {:ok, :success} <- is_author?(post, user.id),
         {:ok, %Post{}} <- Posts.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end

  defp is_author?(post, user_id) do
    case post.user_id == user_id do
      true -> {:ok, :success}
      _ -> {:error, :unauthorized, "Unauthorized user"}
    end
  end

  def map_of_atoms(map) do
    map
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp posts do
    Application.get_env(:blog, :posts)
  end
end
