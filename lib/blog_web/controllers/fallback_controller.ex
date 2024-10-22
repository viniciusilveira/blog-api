defmodule BlogWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BlogWeb, :controller

  def call(conn, {:error, %{errors: [email: {"User already exists", _rules}]} = changeset}) do
    conn
    |> put_status(:conflict)
    |> put_view(BlogWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, status, message}) do
    conn
    |> put_status(status)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: message)
  end

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "invalid fields")
  end
end
