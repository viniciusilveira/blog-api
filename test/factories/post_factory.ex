defmodule Blog.PostFactory do
  @moduledoc false

  alias Blog.Posts.Post

  defmacro __using__(_opts) do
    quote do
      def post_factory do
        %Post{
          title: Faker.Lorem.sentence(7, "..."),
          content: Faker.Lorem.paragraph(1..5)
        }
      end
    end
  end
end
