defmodule Blog.PostsTest do
  use Blog.DataCase
  import Blog.Factory

  alias Blog.Posts
  alias Blog.Posts.Post

  setup do
    user_id = insert(:user).id

    attrs =
      :post
      |> params_for
      |> Map.merge(%{user_id: user_id})

    {:ok, attrs: attrs, user_id: user_id}
  end

  describe "create_post/1" do
    test "create_post/1 with valid data creates a post", %{attrs: attrs} do
      assert {:ok, %Post{} = post} = Posts.create_post(attrs)
      assert post.content == attrs.content
      assert post.title == attrs.title
      assert post.user_id == attrs.user_id
    end

    test "create_post/1 without title returns error changeset", %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Posts.create_post(Map.delete(attrs, :title))

      assert "is required" in errors_on(changeset).title
    end

    test "create_post/1 without content returns error changeset", %{attrs: attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Posts.create_post(Map.delete(attrs, :content))

      assert "is required" in errors_on(changeset).content
    end
  end

  describe "get_post/1" do
    test "returns post data when id is valid", %{user_id: user_id} do
      post = :post |> insert(user_id: user_id) |> Repo.preload(:user)
      assert {:ok, post} == Posts.get_post(post.id)
    end

    test "returns error when id does not exists", %{user_id: user_id} do
      insert(:post, user_id: user_id)
      assert {:error, :not_found, "Post does not exists"} == Posts.get_post(Ecto.UUID.generate())
    end
  end

  describe "list_posts/0" do
    test "when exists posts in database", %{user_id: user_id} do
      posts = insert_pair(:post, user_id: user_id) |> Repo.preload(:user)
      assert posts == Posts.list_posts()
    end

    test "when does not exists posts in database" do
      assert Posts.list_posts() == []
    end
  end

  describe "search_posts/1" do
    test "when search returns results by title", %{user_id: user_id} do
      posts = insert_pair(:post, user_id: user_id, title: "Elixir > Java") |> Repo.preload(:user)
      insert_pair(:post, user_id: user_id, content: "this does not returned")
      assert {:ok, posts} == Posts.search_posts("elixir")
    end

    test "when search returns results by content", %{user_id: user_id} do
      insert_pair(:post, user_id: user_id, title: "this does not returned")

      posts =
        :post
        |> insert_pair(user_id: user_id, content: "Elixir is the best programing language")
        |> Repo.preload(:user)

      assert {:ok, posts} == Posts.search_posts("elixir")
    end

    test "return empty array when don't find any results", %{user_id: user_id} do
      :post
      |> insert_pair(user_id: user_id, content: "Elixir is the best programing language")
      |> Repo.preload(:user)

      assert {:ok, []} == Posts.search_posts("java")
    end
  end

  describe "update_post/2" do
    test "with valid data updates a post" do
      post = insert(:post)
      attrs = params_for(:post)
      assert {:ok, %Post{} = updated_post} = Posts.update_post(post, attrs)
      assert updated_post.title == attrs.title
      assert updated_post.content == attrs.content
    end

    test "without title returns error changeset" do
      post = insert(:post)
      attrs = Map.delete(params_for(:post), :title)
      assert {:error, %Ecto.Changeset{} = changeset} = Posts.update_post(post, attrs)
      assert "is required" in errors_on(changeset).title
    end

    test "without content returns error changeset" do
      post = insert(:post)
      attrs = Map.delete(params_for(:post), :content)
      assert {:error, %Ecto.Changeset{} = changeset} = Posts.update_post(post, attrs)
      assert "is required" in errors_on(changeset).content
    end
  end

  describe "delete_post/1" do
    test "deletes chosen post" do
      post = insert(:post)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert {:error, :not_found, "Post does not exists"}
    end
  end
end
