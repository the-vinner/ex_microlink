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

  def parse_date(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

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

  @doc ~S"""
  Queries the Microlink API for link data

  ## Examples

      iex> ExMicrolink.run(%{url: "https://www.lapresse.ca/sports/hockey/2021-11-26/canadien-sabres/le-retour-de-joel-edmundson-devra-attendre.php"})
      {
        :ok,
        %ExMicrolink.Response{
          author: "Richard Labbé La Presse",
          content_length: 43106,
          content_type: "text/html; charset=UTF-8",
          date: ~U[2021-11-26 16:57:43.000Z],
          date_raw: "2021-11-26T16:57:43.000Z",
          description: "Le Canadien espérait pouvoir miser sur le retour imminent de Joel Edmundson… mais ça devra attendre.",
          error: nil,
          iframe: nil,
          image: %ExMicrolink.Image{
            height: 616,
            id: nil,
            size: 187745,
            size_pretty: "188 kB",
            type: "jpg",
            url: "https://mobile-img.lpcdn.ca/v2/924x/r3996/cfe89f4e158a36afb584bc1528e07ea3.jpg",
            width: 924
          },
          lang: "fr",
          logo: %ExMicrolink.Image{
            height: 192,
            id: nil,
            size: 12311,
            size_pretty: "12.3 kB",
            type: "png",
            url: "https://www.lapresse.ca/android-chrome-192x192.png",
            width: 192
          },
          publisher: "La Presse",
          screenshot: %ExMicrolink.Image{height: nil, id: nil, size: nil, size_pretty: nil, type: nil, url: nil, width: nil},
          status: 200,
          title: "Canadien – Sabres | Le retour de Joel Edmundson devra attendre",
          url: "https://www.lapresse.ca/sports/hockey/2021-11-26/canadien-sabres/le-retour-de-joel-edmundson-devra-attendre.php"
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
        |> transform_to_response(Ecto.Changeset.get_field(cs, :url))
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
  } = resp, _) do
    %Response{
      author: author,
      content_length: parse_content_length(headers["content-length"]),
      content_type: headers["content-type"],
      date: parse_date(date),
      date_raw: date,
      description: description,
      image: ExMicrolink.Image.changeset(resp.body["data"]["image"]),
      iframe: parse_iframe(resp.body["data"]["iframe"]),
      lang: lang,
      logo: ExMicrolink.Image.changeset(resp.body["data"]["logo"]),
      publisher: publisher,
      screenshot: ExMicrolink.Image.changeset(resp.body["data"]["screenshot"]),
      status: 200,
      title: title,
      url: url
    }
  end
  def transform_to_response(%Req.Response{body: body, status: status}, url) do
    %Response{
      error: body,
      url: url,
      status: status
    }
  end
end
