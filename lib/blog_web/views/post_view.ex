defmodule BlogWeb.PostView do
  use BlogWeb, :view
  alias BlogWeb.{PostView, UserView}

  def render("index.json", %{posts: []}), do: []

  def render("index.json", %{posts: posts}) do
    render_many(posts, PostView, "post_with_user.json")
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("show_with_user.json", %{post: post}) do
    render_one(post, PostView, "post_with_user.json")
  end

  def render("post.json", %{post: post}) do
    %{
      title: post.title,
      content: post.content,
      user_id: post.user_id
    }
  end

  def render("post_with_user.json", %{post: post}) do
    %{
      id: post.id,
      published: post.inserted_at,
      updated: post.updated_at,
      title: post.title,
      content: post.content,
      user: render_one(post.user, UserView, "user.json")
    }
  end
end
