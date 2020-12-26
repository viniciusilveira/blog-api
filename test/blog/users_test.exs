defmodule Blog.UsersTest do
  use Blog.DataCase

  alias Blog.Users

  import Blog.Factory

  describe "create_user" do
    alias Blog.Users.User

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
end
