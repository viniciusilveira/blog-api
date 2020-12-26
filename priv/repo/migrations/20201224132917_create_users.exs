defmodule Blog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :display_name, :string
      add :email, :string, null: false
      add :password, :binary, null: false
      add :image, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
