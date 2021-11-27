defmodule ExMicrolink.Request do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :iframe, :boolean
    field :screenshot, :boolean
    field :no_cache, :boolean
    field :url, :string
    field :wait_for_timeout, :integer
    field :wait_until, :string
    embeds_one :viewport, ExMicrolink.Viewport
  end

  @required_fields [:url]
  @optional_fields [:iframe, :screenshot, :no_cache, :wait_for_timeout, :wait_until]

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_embed(:viewport)
    |> validate_required(@required_fields)
  end
end

defimpl String.Chars, for: ExMicrolink.Request do
  def to_string(req) do
    Map.from_struct(req)
    |> Enum.reduce(
      [],
      fn
        {_, false}, acc -> acc
        {_, nil}, acc -> acc
        {:no_cache, true}, acc ->
          acc ++ ["force=1"]
        {:url, url}, acc ->
          acc ++ ["url=#{URI.encode_www_form(url)}"]
        {k, v}, acc ->
          acc ++ [
            "#{ExMicrolink.Utils.camelize(Kernel.to_string(k))}=#{Kernel.to_string(v)}"
          ]
        _, acc -> acc
      end
    )
    |> Enum.join("&")
  end
end