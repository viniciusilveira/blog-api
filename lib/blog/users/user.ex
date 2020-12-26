defmodule Blog.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Argon2

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :display_name, :string
    field :email, :string
    field :image, :string
    field :password, :binary

    timestamps()
  end

  @optional_fields ~w(display_name image)a
  @required_fields ~w(email password)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields, message: "is required")
    |> validate_length(:display_name,
      min: 8,
      message: "length must be at least %{count} characters long"
    )
    |> validate_format(
      :email,
      ~r/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/i,
      message: "must be a valid email"
    )
    |> validate_length(:password,
      min: 6,
      message: "length must be at least %{count} characters long"
    )
    |> put_password_hash()
    |> unique_constraint(:email, message: "User already exists")
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
