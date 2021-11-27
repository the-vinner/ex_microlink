defmodule ExMicrolink do
  alias ExMicrolink.{Request, Response}
  @endpoint URI.parse("https://api.microlink.io")

  @moduledoc """
  Documentation for `ExMicrolink`.
  """

  def api_key do
    Application.get_env(:ex_microlink, :key)
  end

  def default_headers do
    []
  end

  def parse_content_length(l) when is_binary(l) do
    Integer.parse(l) |> elem(0)
  end
  def parse_content_length(_), do: nil

  def parse_iframe(%{
    "html" => html,
    "scripts" => scripts
  }) do
    %{
      html: HtmlSanitizeEx.html5(html),
      scripts: Enum.map(
        scripts || [],
        fn %{"async" => a, "src" => src, "charset" => c} ->
          %{
            async: a,
            charset: c,
            src: src
          }
        end
      )
    }
  end
  def parse_iframe(_), do: nil

  def parse_image(%{
    "height" => h,
    "size" => size,
    "size_pretty" => size_pretty,
    "type" => type,
    "url" => url,
    "width" => w
  }) do
    %{
      height: h,
      size: size,
      size_pretty: size_pretty,
      type: type,
      url: url,
      width: w
    }
  end
  def parse_image(l), do: l

  @doc ~S"""
  Queries the Microlink API for link daa

  ## Examples

      iex> ExMicrolink.run(%{url: "https://en.wikipedia.org/wiki/Richard_Feynman"})
      {
        :ok,
        %ExMicrolink.Response{
          author: "Contributors to Wikimedia projects",
          content_length: 109606,
          content_type: "text/html; charset=UTF-8",
          date: "2021-11-25T23:05:20.000Z",
          description: "Richard Feynman",
          error: nil,
          iframe: nil,
          image: %{
            height: 396,
            size: 55543,
            size_pretty: "55.5 kB",
            type: "jpg",
            url: "https://upload.wikimedia.org/wikipedia/en/4/42/Richard_Feynman_Nobel.jpg",
            width: 280
          },
          lang: "en",
          logo: %{
            height: 160,
            size: 1313,
            size_pretty: "1.31 kB",
            type: "png",
            url: "https://en.wikipedia.org/static/apple-touch/wikipedia.png",
            width: 160
          },
          publisher: "Wikimedia Foundation, Inc.",
          screenshot: nil,
          status: 200,
          title: "Richard Feynman - Wikipedia",
          url: "https://en.wikipedia.org/wiki/Richard_Feynman"
        }
      }

  """
  def run(request) do
    Request.changeset(request)
    |> case do
      %Ecto.Changeset{valid?: false} = cs ->
        {:error, cs}
      cs ->
        @endpoint
        |> Map.replace!(
          :query,
          to_string(
            Ecto.Changeset.apply_changes(cs)
          )
        )
        |> to_string
        |> Req.get!([
          headers: default_headers(),
          finch_options: [
            receive_timeout: 60_000
          ]
        ])
        |> transform_to_response
        |> then(fn res -> {:ok, res} end)
    end
  end

  def transform_to_response(%Req.Response{
    body: %{
      "data" => %{
        "author" => author,
        "date" => date,
        "description" => description,
        # %{
        #   "html" => "<iframe style=\"border: none;\" height=\"450\" width=\"800\" src=\"https://www.figma.com/embed?embed_host=oembed&url=https://www.figma.com/file/B3Bvd7OgWS1yx9KqanvCXu/Untitled\"></iframe>",
        #   "scripts" => []
        # },
        # %{
        #   "height" => 617,
        #   "size" => 58297,
        #   "size_pretty" => "58.3 kB",
        #   "type" => "png",
        #   "url" => "https://s3-alpha-sig.figma.com/thumbnails/B3Bvd7OgWS1yx9KqanvCXu/default?Expires=1637539200&Signature=Z8GKayfck1rUP6CnA9jcStFg~wtrpMNIVOVdI8Jqkb~CBfS2PFrJf5csfL-2D4Vm1w9dbARzQPb--QSLylgba3NOw5saLpL-PTBDBmyVPTIgArrZc-W05-7F5TLWj1Oep~13F7ucaf9tUl4rs2M~gxYkbUxMb5zlCSYwkGK8YtUMiMsm7VAa9HMnh-6b9U1IjdFAKkGrgVQnolXxStiwTQDJkt~8ZFE1jxxYa8Q7efFJEt-alQ2tZLGpTtyA9lTSDSdpb7toLqzuMgs9HQS7klE5iQAxmdwif5ncnwXw0mLbWg44W0-XIvYv9o4gKe9x6~OZC3RilYroRBXygogZ7g__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA",
        #   "width" => 800
        # },
        "lang" => lang,
        # "logo" => %{
        #   "height" => 192,
        #   "size" => 10012,
        #   "size_pretty" => "10 kB",
        #   "type" => "png",
        #   "url" => "https://static.figma.com/app/icon/1/icon-192.png",
        #   "width" => 192
        # },
        "publisher" => publisher,
        "title" => title,
        "url" => url
      },
      "headers" => headers
      # "headers" => %{
      #   "accept-ranges" => "bytes",
      #   "age" => "440",
      #   "cache-control" => "must-revalidate, public, max-age=0",
      #   "connection" => "close",
      #   "content-length" => "3028",
      #   "content-security-policy" => "upgrade-insecure-requests;",
      #   "content-type" => "application/pdf",
      #   "date" => "Thu, 11 Nov 2021 02:40:20 GMT",
      #   "expires" => "Thu, 18 Nov 2021 02:33:00 GMT",
      #   "last-modified" => "Tue, 23 Mar 2021 21:26:04 GMT",
      #   "server" => "Apache",
      #   "strict-transport-security" => "max-age=15768000",
      #   "via" => "1.1 varnish (Varnish/6.5)",
      #   "x-cache" => "HIT",
      #   "x-cacheable" => "YES:Forced",
      #   "x-powered-by" => "DreamPress",
      #   "x-varnish" => "3417070 4498774"
      # },
    },
    status: 200
  } = resp) do
    %Response{
      author: author,
      content_length: parse_content_length(headers["content-length"]),
      content_type: headers["content-type"],
      date: date,
      description: description,
      image: parse_image(resp.body["data"]["image"]),
      iframe: parse_iframe(resp.body["data"]["iframe"]),
      lang: lang,
      logo: parse_image(resp.body["data"]["logo"]),
      publisher: publisher,
      screenshot: parse_image(resp.body["data"]["screenshot"]),
      status: 200,
      title: title,
      url: url
    }
  end
  def transform_to_response(%Req.Response{body: body, status: status}) do
    %Response{
      error: body,
      status: status
    }
  end
end
