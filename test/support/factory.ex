defmodule Blog.Factory do
  use ExMachina.Ecto, repo: Blog.Repo

  use Blog.UserFactory
end
