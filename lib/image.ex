defmodule ExMicrolink.Image do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :height, :integer
    field :size, :integer
    field :size_pretty, :string
    field :type, :string
    field :url, :string
    field :width, :integer
  end

  @optional_fields [
    :height,
    :size,
    :size_pretty,
    :type,
    :url,
    :width
  ]

  def changeset(nil), do: changeset(%{})
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs || %{}, @optional_fields)
    |> apply_changes
  end
end