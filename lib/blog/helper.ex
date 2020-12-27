defmodule Blog.Helper do
  def atomize(map) do
    map
    |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
  end
end
