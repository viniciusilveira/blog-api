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
  @type t :: %{display_name: charlist, email: charlist, password: charlist, image: charlist}

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
end
