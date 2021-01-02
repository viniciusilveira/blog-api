defmodule Blog.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Users.User

  @doc """
  List all users

  ## Examples

      iex> list_users()
        %{%User{}, %User{}, ...}
  """
  @spec list_users() :: list
  def list_users(), do: Repo.all(User)

  @doc """
  Gets a single user.

  Returns not_found error if the User does not exist.

  ## Examples

      iex> get_user("514a6e41-b377-48bf-9087-c01cc6e028f9")
      %User{}

      iex> get_user(123)
      {:error, :not_found, "message"}

  """
  @spec get_user(binary) :: {:ok, %User{}} | {:error, :not_found, String.t()}
  def get_user(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found, "User does not exists"}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{
        display_name: "Vinicius Silveira",
        email: "vini@mail.com
        password: "12345",
        image: "http://ima.ge/profile
      })
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  @type create_attrs :: %{
          display_name: String.t(),
          email: String.t(),
          password: String.t(),
          image: String.t()
        }

  @spec create_user(create_attrs()) :: {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Delete a user

  ## Examples

      iex> delete_user(user)
      {:ok, %{}}

      iex> delete_user(user)
      {:error, %Changeset{}}
  """
  @spec delete_user(%User{}) :: {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def delete_user(user), do: Repo.delete(user)

  @doc """
  Authenticate user

  ## Examples

      iex> authenticate("vini@mail.com", "123456")
      {:ok, %User{}}

      iex> authenticate("vini@mail.com", "invalid")
      {:error, :invalid_credentials}
  """
  @type auth_attrs :: %{password: String.t(), email: String.t()}
  @spec authenticate(auth_attrs()) ::
          {:ok, %User{}} | {:error, %Ecto.Changeset{}} | {:error, :invalid_credentials}
  def authenticate(attrs) do
    with %Ecto.Changeset{valid?: true} <- User.login_changeset(attrs),
         %User{} = user <-
           get_user_by_email(attrs.email) do
      verify_pass(attrs.password, user)
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  defp verify_pass(plain_text_password, user) do
    case Argon2.verify_pass(plain_text_password, user.password) do
      true -> {:ok, user}
      _ -> {:error, :invalid_credentials}
    end
  end

  defp get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
