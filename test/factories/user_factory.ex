defmodule Blog.UserFactory do
  alias Blog.Users.User

  alias Faker.Internet

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          display_name: Faker.Person.name(),
          email: Internet.email(),
          password: "12345678",
          image: Internet.url()
        }
      end
    end
  end
end
