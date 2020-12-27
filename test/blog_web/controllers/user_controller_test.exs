defmodule BlogWeb.UserControllerTest do
  use BlogWeb.ConnCase

  import Blog.Factory

  alias Blog.{Guardian, Users}

  describe "#POST /user" do
    @valid_attrs string_params_for(:user)

    setup %{conn: conn} do
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
    end

    test "renders user token when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @valid_attrs)
      assert %{"token" => _token} = json_response(conn, 201)
    end

    test "renders error message when display_name size it's smaller than 8 characters", %{
      conn: conn
    } do
      attrs = Map.merge(@valid_attrs, %{"display_name" => "Vini"})
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert response = json_response(conn, 400)
      assert response["message"] == "\"display_name\" length must be at least 8 characters long"
    end

    test "renders error message when email is invalid", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{"email" => "inva@lid"})
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert response = json_response(conn, 400)

      assert response["message"] == "\"email\" must be a valid email"
    end

    test "renders error message when email is empty", %{conn: conn} do
      attrs = Map.delete(@valid_attrs, "email")
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert response = json_response(conn, 400)
      assert response["message"] == "\"email\" is required"
    end

    test "renders error message when password size it's smaller than 6 characters", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{"password" => "12345"})
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert response = json_response(conn, 400)
      assert response["message"] == "\"password\" length must be at least 6 characters long"
    end

    test "renders error message when password is empty", %{conn: conn} do
      attrs = Map.delete(@valid_attrs, "password")
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      assert response = json_response(conn, 400)
      assert response["message"] == "\"password\" is required"
    end

    test "renders error message when email already exists", %{conn: conn} do
      insert(:user, email: @valid_attrs["email"])
      conn = post(conn, Routes.user_path(conn, :create), user: @valid_attrs)
      assert response = json_response(conn, 409)
      assert response["message"] == "User already exists"
    end
  end

  describe "#GET /user" do
    setup %{conn: conn} do
      {:ok, user} = Users.create_user(params_for(:user))
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      {:ok, conn: conn}
    end

    test "renders all users", %{conn: conn} do
      insert_pair(:user)
      conn = get(conn, Routes.user_path(conn, :index))
      assert response = json_response(conn, 200)

      assert Enum.count(response) == 3
    end

    test "renders error when token does not send", %{conn: conn} do
      conn = delete_req_header(conn, "authorization")
      conn = get(conn, Routes.user_path(conn, :index))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = get(conn, Routes.user_path(conn, :index))

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#GET /user/:id" do
    setup %{conn: conn} do
      {:ok, user} = Users.create_user(params_for(:user))
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      {:ok, conn: conn, user: user}
    end

    test "render a requested user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert response = json_response(conn, 200)

      assert response["id"] == user.id
      assert response["display_name"] == user.display_name
      assert response["email"] == user.email
      assert response["image"] == user.image
    end

    test "render a error message when user not found", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, Ecto.UUID.generate()))
      assert response = json_response(conn, 404)

      assert response["message"] == "User does not exists"
    end

    test "renders error when token does not send", %{conn: conn, user: user} do
      conn = delete_req_header(conn, "authorization")
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn, user: user} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = get(conn, Routes.user_path(conn, :show, user.id))

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end

  describe "#DELETE /user/me" do
    setup %{conn: conn} do
      {:ok, user} = Users.create_user(params_for(:user))
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      {:ok, conn: conn, user: user}
    end

    test "render success when user is deleted", %{conn: conn, user: %{id: id}} do
      conn = delete(conn, Routes.user_path(conn, :delete))
      assert conn.status == 204

      assert Users.get_user(id) == {:error, :not_found, "User does not exists"}
    end

    test "renders error when token does not send", %{conn: conn} do
      conn = delete_req_header(conn, "authorization")
      conn = delete(conn, Routes.user_path(conn, :delete))
      assert response = json_response(conn, 401)

      assert response["message"] == "Token not found"
    end

    test "renders error when token is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "invalidtoken")
      conn = delete(conn, Routes.user_path(conn, :delete))

      assert response = json_response(conn, 401)

      assert response["message"] == "Token is expired or invalid"
    end
  end
end
