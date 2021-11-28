defmodule ExMicrolink.Response do
  use TypedStruct
  typedstruct do
    field :author, String.t()
    field :content_length, String.t()
    field :content_type, String.t()
    field :date, DateTime.t()
    field :date_raw, String.t()
    field :description, String.t()
    field :error, String.t()
    field :image, map()
    field :iframe, map()
    field :lang, String.t()
    field :logo, map()
    field :publisher, String.t()
    field :screenshot, map()
    field :title, String.t()
    field :url, String.t()
    field :status, integer(), default: 200
  end
end