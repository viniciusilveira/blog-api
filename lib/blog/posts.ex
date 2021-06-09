defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post

  @behaviour Blog.PostBehaviour

  @impl true
  def list_posts do
    Post
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @impl true
  def search_posts(term) do
    query =
      from p in Post,
        where: ilike(p.title, ^"%#{term}%"),
        or_where: ilike(p.content, ^"%#{term}%")

    {:ok, Repo.all(query) |> Repo.preload(:user)}
  end

  @impl true
  def get_post(id) do
    case Repo.get(Post, id) do
      %Post{} = post -> {:ok, post |> Repo.preload(:user)}
      nil -> {:error, :not_found, "Post does not exists"}
    end
  end

  @impl true
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @impl true
  def update_post(%Post{} = post, attrs) do
    case Post.valid_update_changeset(attrs) do
      %Ecto.Changeset{valid?: true} ->
        post
        |> Post.update_changeset(attrs)
        |> Repo.update()

      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  @impl true
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end
end
