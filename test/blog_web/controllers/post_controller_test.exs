defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.Factory

  alias Blog.{Guardian, Users}

  @valid_attrs string_params_for(:post)

  setup %{conn: conn} do
    {:ok, user} = Users.create_user(params_for(:user))
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "#POST /posts" do
    test "renders post when data is valid", %{conn: conn, user: %{id: user_id}} do
      conn = post(conn, Routes.post_path(conn, :create), @valid_attrs)

      assert response = json_response(conn, 201)
      assert response["content"] == @valid_attrs["content"]
      assert response["title"] == @valid_attrs["title"]
      assert response["user_id"] == user_id
    end

    test "renders error message when title  is empty", %{conn: conn} do
      attrs = Map.delete(@valid_attrs, "title")
      conn = post(conn, Routes.post_path(conn, :create), attrs)

      assert response = json_response(conn, 400)
      assert response["message"] == "\"title\" is required"
    end

    test "renders error message when content  is empty", %{conn: conn} do
      attrs = Map.delete(@valid_attrs, "content")
      conn = post(conn, Routes.post_path(conn, :create), attrs)

      assert response = json_response(conn, 400)
      assert response["message"] == "\"content\" is required"
    end

    test "renders error when token does not send", %{conn: conn} do
      conn = delete_req_header(conn, "authorization")
      conn = post(conn, Routes.post_path(conn, :create), @valid_attrs)
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = post(conn, Routes.post_path(conn, :create), @valid_attrs)
      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#GET /post" do
    test "render all posts", %{conn: conn, user: %{id: user_id}} do
      insert_pair(:post, user_id: user_id)
      conn = get(conn, Routes.post_path(conn, :index))
      assert response = json_response(conn, 200)
      assert Enum.count(response) == 2
    end

    test "renders error when token does not send", %{conn: conn} do
      conn = delete_req_header(conn, "authorization")
      conn = get(conn, Routes.post_path(conn, :index))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = get(conn, Routes.post_path(conn, :index))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#GET post/:id" do
    alias Blog.Repo

    test "render a requested post", %{conn: conn, user: %{id: user_id}} do
      post = :post |> insert(user_id: user_id) |> Repo.preload(:user)

      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert response = json_response(conn, 200)
      assert response["id"] == post.id
      assert response["user"]["id"] == post.user_id
    end

    test "render a error message when post not found", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, Ecto.UUID.generate()))
      assert response = json_response(conn, 404)

      assert response["message"] == "Post does not exists"
    end

    test "renders error when token does not send", %{conn: conn} do
      post = insert(:post)
      conn = delete_req_header(conn, "authorization")
      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      post = insert(:post)
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = get(conn, Routes.post_path(conn, :show, post.id))

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#GET /post/search?q=search_term" do
    test "render all searched posts by title", %{conn: conn, user: %{id: user_id}} do
      insert_pair(:post, user_id: user_id, title: "Elixir > Java")
      conn = get(conn, "/api/post/search?q=elixir")
      assert response = json_response(conn, 200)
      assert Enum.count(response) == 2
    end

    test "render all searched posts by content", %{conn: conn, user: %{id: user_id}} do
      insert_pair(:post, user_id: user_id, title: "Elixir > Java")
      insert_pair(:post, user_id: user_id, content: "Elixir is the best programing language")
      conn = get(conn, "/api/post/search?q=programing language")
      assert response = json_response(conn, 200)
      assert Enum.count(response) == 2
    end

    test "render a error message when posts not found", %{conn: conn, user: %{id: user_id}} do
      insert_pair(:post, user_id: user_id, title: "Elixir > Java")
      insert_pair(:post, user_id: user_id, content: "Elixir is the best programing language")
      conn = get(conn, "/api/post/search?q=isto non ecziste")
      assert [] = json_response(conn, 200)
    end

    test "renders error when token does not send", %{conn: conn, user: %{id: user_id}} do
      conn = delete_req_header(conn, "authorization")
      insert_pair(:post, user_id: user_id, title: "Elixir > Java")
      conn = get(conn, "/api/post/search?q=elixir")
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn, user: %{id: user_id}} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      insert_pair(:post, user_id: user_id, title: "Elixir > Java")
      conn = get(conn, "/api/post/search?q=elixir")
      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#PUT /post" do
    test "renders post when data is valid", %{conn: conn, user: %{id: user_id}} do
      post = insert(:post, user_id: user_id)

      conn =
        put(conn, Routes.post_path(conn, :update, post), %{
          title: "New title",
          content: "New content"
        })

      assert %{"content" => "New content", "title" => "New title", "user_id" => user_id} ==
               json_response(conn, 200)
    end

    test "renders error when user does not author", %{conn: conn} do
      post = insert(:post)

      conn =
        put(conn, Routes.post_path(conn, :update, post), %{
          title: "New title",
          content: "New content"
        })

      assert response = json_response(conn, 401)
      assert response["message"] == "Unauthorized user"
    end

    test "renders errors when request does not have title", %{conn: conn, user: %{id: user_id}} do
      post = insert(:post, user_id: user_id)
      conn = put(conn, Routes.post_path(conn, :update, post), %{content: "New content"})
      assert response = json_response(conn, 400)

      assert response["message"] == "\"title\" is required"
    end

    test "renders errors when request does not have content", %{conn: conn, user: %{id: user_id}} do
      post = insert(:post, user_id: user_id)
      conn = put(conn, Routes.post_path(conn, :update, post), %{title: "New title"})
      assert response = json_response(conn, 400)

      assert response["message"] == "\"content\" is required"
    end

    test "renders error when token does not send", %{conn: conn} do
      post = insert(:post)
      conn = delete_req_header(conn, "authorization")

      conn =
        put(conn, Routes.post_path(conn, :update, post), %{
          title: "New title",
          content: "New content"
        })

      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      post = insert(:post)
      conn = put_req_header(conn, "authorization", "invalidtoken")

      conn =
        put(conn, Routes.post_path(conn, :update, post), %{
          title: "New title",
          content: "New content"
        })

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "delete post" do
    alias Blog.Posts

    test "deletes chosen post", %{conn: conn, user: %{id: user_id}} do
      post = insert(:post, user_id: user_id)
      conn = delete(conn, Routes.post_path(conn, :delete, post))
      assert response(conn, 204)

      assert {:error, :not_found, "Post does not exists"} = Posts.get_post(post.id)
    end

    test "does not deletes chosen post when user is not author", %{conn: conn} do
      post = insert(:post)
      conn = delete(conn, Routes.post_path(conn, :delete, post))
      assert response = json_response(conn, 401)
      assert response["message"] == "Unauthorized user"
    end

    test "renders error when post does not exists", %{conn: conn} do
      conn = delete(conn, Routes.post_path(conn, :delete, Ecto.UUID.generate()))
      assert response = json_response(conn, 404)
      assert response["message"] == "Post does not exists"
    end

    test "renders error when token does not send", %{conn: conn} do
      post = insert(:post)
      conn = delete_req_header(conn, "authorization")
      conn = delete(conn, Routes.post_path(conn, :delete, post))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      post = insert(:post)
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = delete(conn, Routes.post_path(conn, :delete, post))

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end
end
