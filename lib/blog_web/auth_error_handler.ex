defmodule Blog.AuthErrorHandler do
  @moduledoc false

  use Phoenix.Controller, namespace: BlogWeb

  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})

    conn
    |> resp(401, body)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: error_message(conn))
  end

  defp error_message(conn) do
    case get_req_header(conn, "authorization") do
      [] -> "Token not found"
      _ -> "Token is expired or invalid"
    end
  end
end
