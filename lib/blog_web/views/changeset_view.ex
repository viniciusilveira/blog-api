defmodule BlogWeb.ChangesetView do
  use BlogWeb, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `BlogWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    changeset
    |> traverse_errors()
    |> prettify_errors()
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{message: translate_errors(changeset)}
  end

  defp traverse_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp prettify_errors(errors) do
    Enum.reduce(errors, "", fn {key, value}, _acc ->
      joined_errors = Enum.join(value, "; ")

      case {key, joined_errors} do
        {:email, "User already exists"} -> joined_errors
        _ -> "\"#{key}\" #{joined_errors}"
      end
    end)
  end
end
