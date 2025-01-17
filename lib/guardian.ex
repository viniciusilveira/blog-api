defmodule Blog.Guardian do
  @moduledoc """
    Moodule to implements the token generates logic
  """

  use Guardian, otp_app: :blog

  alias Blog.Users
  alias Blog.Users.User

  def subject_for_token(%User{} = user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}), do: Users.get_user(id)

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
