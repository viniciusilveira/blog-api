defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  @spec list_posts() :: {:ok, list}
  def list_posts do
    Post
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Returns the posts founds

  ## Examples

      iex> search_posts(term)
      [%Post{}, ...]
  """
  @spec search_posts(String.t()) :: {:ok, list}
  def search_posts(term) do
    query =
      from p in Post,
        where: ilike(p.title, ^"%#{term}%"),
        or_where: ilike(p.content, ^"%#{term}%")

    {:ok, Repo.all(query) |> Repo.preload(:user)}
  end

  @doc """
  Gets a single post.

  ## Examples

      iex> get_post(123)
      %Post{}

      iex> get_post(456)
      {:error, :not_found, "message"}

  """
  @spec get_post(String.t()) :: {:ok, list} | {:error, :not_found, String.t()}
  def get_post(id) do
    case Repo.get(Post, id) do
      %Post{} = post -> {:ok, post |> Repo.preload(:user)}
      nil -> {:error, :not_found, "Post does not exists"}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{title: "Foo title" , content: "Foo content", user_id: "59f8b8c3-9a2e-43dc-a406-ae1cc85fea44"})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @type create_attrs :: %{title: String.t(), content: String.t(), user_id: binary}
  @spec create_post(create_attrs()) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{title: "Foo title" , content: "Foo content"})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @type update_attrs :: %{title: String.t(), content: String.t()}
  @spec update_post(%Post{}, update_attrs()) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}
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

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_post(%Post{}) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end
end
