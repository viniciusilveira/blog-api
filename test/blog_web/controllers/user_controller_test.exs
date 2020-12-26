defmodule BlogWeb.UserControllerTest do
  use BlogWeb.ConnCase

  import Blog.Factory

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
end
