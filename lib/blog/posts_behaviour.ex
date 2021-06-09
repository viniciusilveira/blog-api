defmodule Blog.PostsBehaviour do
  @moduledoc """
    Post Behaviour for Posts context
  """
  alias Blog.Posts.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  @callback list_posts :: {:ok, list()}

  @doc """
  Returns the posts founds

  ## Examples

      iex> search_posts(term)
      [%Post{}, ...]
  """
  @callback search_posts(String.t()) :: {:ok, list()}

  @doc """
  Gets a single post.

  ## Examples

      iex> get_post(123)
      %Post{}

      iex> get_post(456)
      {:error, :not_found, "message"}

  """
  @callback get_post(String.t()) :: {:ok, list()} | {:error, :not_found, String.t()}

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{title: "Foo title" , content: "Foo content", user_id: "59f8b8c3-9a2e-43dc-a406-ae1cc85fea44"})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @type create_attrs :: %{title: String.t(), content: String.t(), user_id: binary}
  @callback create_post(create_attrs()) :: {:ok, Post.t()} | {:error, %Ecto.Changeset{}}

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{title: "Foo title" , content: "Foo content"})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @type update_attrs :: %{title: String.t(), content: String.t()}
  @callback update_post(Post.t(), update_attrs) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  @callback delete_post(Post.t()) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}
end
