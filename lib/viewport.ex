defmodule ExMicrolink.Viewport do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :device_scale_factor, :integer
    field :height, :integer
    field :is_mobile, :boolean
    field :width, :integer
  end

  @required_fields [:height, :width]
  @optional_fields [:is_mobile, :device_scale_factor]

  def changeset(s, attrs) do
    s
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end