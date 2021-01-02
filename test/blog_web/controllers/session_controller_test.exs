defmodule BlogWeb.SessionControllerTest do
  use BlogWeb.ConnCase

  import Blog.Factory

  alias Blog.Users

  describe "#POST /login" do
    setup %{conn: conn} do
      user_params = params_for(:user)
      Users.create_user(user_params)
      auth_attrs = %{"email" => user_params.email, "password" => user_params.password}
      {:ok, conn: put_req_header(conn, "accept", "application/json"), auth_attrs: auth_attrs}
    end

    test "render token when email and password is valid", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", auth_attrs)

      assert %{"token" => _token} = json_response(conn, 200)
    end

    test "render error message when email is nil", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", Map.delete(auth_attrs, "email"))

      assert response = json_response(conn, 400)
      assert response["message"] == "\"email\" is required"
    end

    test "render error message when password is nil", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", Map.delete(auth_attrs, "password"))

      assert response = json_response(conn, 400)
      assert response["message"] == "\"password\" is required"
    end

    test "render error message when email is empty", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", Map.merge(auth_attrs, %{"email" => ""}))

      assert response = json_response(conn, 400)
      assert response["message"] == "\"email\" is not allowed to be empty"
    end

    test "render error message when password is empty", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", Map.merge(auth_attrs, %{"password" => ""}))

      assert response = json_response(conn, 400)
      assert response["message"] == "\"password\" is not allowed to be empty"
    end

    test "render error message when password is invalid", %{conn: conn, auth_attrs: auth_attrs} do
      conn = post(conn, "/login", Map.merge(auth_attrs, %{"password" => "invalidpasswd"}))

      assert response = json_response(conn, 400)
      assert response["message"] == "invalid fields"
    end
  end
end
