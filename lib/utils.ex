defmodule ExMicrolink.Utils do
  def camelize(word, opts \\ [])
  def camelize("_" <> word, opts) do
    "_" <> camelize(word, opts)
  end
  def camelize(word, opts) do
    case opts |> Enum.into(%{}) do
      %{lower: true} ->
        {first, rest} = String.split_at(Macro.camelize(word), 1)
        String.downcase(first) <> rest

      _ ->
        Macro.camelize(word)
    end
  end 
end