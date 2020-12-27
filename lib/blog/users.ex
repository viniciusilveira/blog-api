defmodule Blog.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Users.User

  @typedoc """
    Type that represents a structure of User
  """
  @type t(display_name, email, password, image) :: %{
          display_name: display_name,
          email: email,
          password: password,
          image: image
        }
  @type t :: %{
          display_name: String.t(),
          email: String.t(),
          password: String.t(),
          image: String.t()
        }

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("514a6e41-b377-48bf-9087-c01cc6e028f9")
      %User{}

      iex> get_user!(123)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(charlist) :: %User{}
  def get_user!(id), do: Repo.get!(User, id)

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
  @spec create_user(t()) ::
          %User{}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticate user

  ## Examples

      iex> authenticate("vini@mail.com", "123456")
      {:ok, %User{}}

      iex> authenticate("vini@mail.com", "invalid")
      {:error, :invalid_credentials}
  """
  @spec authenticate(%{password: String.t(), email: String.t()}) :: {:ok, %User{}}
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
