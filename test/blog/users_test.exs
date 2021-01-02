defmodule Blog.UsersTest do
  use Blog.DataCase

  alias Blog.Users
  alias Blog.Users.User

  import Blog.Factory

  describe "create_user/1" do
    @valid_attrs params_for(:user)

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)

      assert user.display_name == @valid_attrs.display_name
      assert user.email == @valid_attrs.email
      assert user.image == @valid_attrs.image
    end

    test "create_user/1 with display_name size > 8 characters returns error changset" do
      attrs = Map.merge(@valid_attrs, %{display_name: "Vini"})
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(attrs)
      assert "length must be at least 8 characters long" in errors_on(changeset).display_name
    end

    test "create_user/1 with invalid email returns error changeset" do
      attrs = Map.merge(@valid_attrs, %{email: "invalid@"})
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(attrs)

      assert "must be a valid email" in errors_on(changeset).email
    end

    test "create_user/1 without email returns error changeset" do
      attrs = Map.delete(@valid_attrs, :email)
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(attrs)

      assert "is required" in errors_on(changeset).email
    end

    test "create_user/1 with pasword less than 6 characters returns error changeset" do
      attrs = Map.merge(@valid_attrs, %{password: "12345"})
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(attrs)

      assert "length must be at least 6 characters long" in errors_on(changeset).password
    end

    test "create_user/1 without password returns error changeset" do
      attrs = Map.delete(@valid_attrs, :password)
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(attrs)

      assert "is required" in errors_on(changeset).password
    end

    test "create_user/1 with a duplicate email returns changeset error" do
      assert {:ok, _user} = Users.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(@valid_attrs)

      assert "User already exists" in errors_on(changeset).email
    end
  end

  describe "authenticate/2" do
    setup do
      user_attrs = params_for(:user)
      Users.create_user(user_attrs)

      {:ok, user_attrs: %{email: user_attrs.email, password: user_attrs.password}}
    end

    test "authenticate/2 with valid data returns user", %{user_attrs: user_attrs} do
      assert {:ok, %User{} = user} = Users.authenticate(user_attrs)
      assert user.email == user_attrs.email
    end

    test "authenticate/2 without email returns error", %{user_attrs: user_attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.authenticate(Map.delete(user_attrs, :email))

      assert "is required" in errors_on(changeset).email
    end

    test "authenticate/2 without password returns error", %{user_attrs: user_attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.authenticate(Map.delete(user_attrs, :password))

      assert "is required" in errors_on(changeset).password
    end

    test "authenticate/2 with empty email returns error", %{user_attrs: user_attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.authenticate(Map.merge(user_attrs, %{email: ""}))

      assert "is not allowed to be empty" in errors_on(changeset).email
    end

    test "authenticate/2 with empty password returns error", %{user_attrs: user_attrs} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.authenticate(Map.merge(user_attrs, %{password: ""}))

      assert "is not allowed to be empty" in errors_on(changeset).password
    end

    test "authenticate/2 with invalid credentials returns error" do
      assert {:error, :invalid_credentials} =
               Users.authenticate(%{email: "not_registered@email.com", password: "11111111"})
    end
  end

  describe "delete_user/1" do
    test "delete_user/1 when user exists" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)

      assert Users.get_user(user.id) == {:error, :not_found, "User does not exists"}
    end
  end
end
