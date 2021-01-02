defmodule Blog.Posts.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Users.User
  alias Blog.Posts.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :content, :string
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w(title content user_id)a

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields, message: "is required")
  end

  @upgradeable_fields ~w(title content)a

  @doc false
  def update_changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields)
    |> validate_required(@upgradeable_fields, message: "is required")
  end

  @doc false
  def valid_update_changeset(attrs) do
    %Post{}
    |> change(attrs)
    |> validate_required(@upgradeable_fields, message: "is required")
  end
end
