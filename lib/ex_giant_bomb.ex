defmodule ExGiantBomb do
  use HTTPoison.Base

  @type map_result :: {:ok, map} | {:error, String.t}
  @type game_id :: String.t

  defp process_url(url) do
    "https://www.giantbomb.com/api" <> url
  end

  defp process_response_body(raw_body) do
    case Poison.decode!(raw_body) do
      body = %{"error" => "OK"} -> {:ok, body}
      %{"error" => error}       -> {:error, error}
    end
  end

  defp make_request_opts(api_key, rest \\ []) do
    [
      params: rest ++ [
        api_key: api_key,
        format: "json",
      ]
    ]
  end

  defp raise_api_key_error, do: raise ArgumentError, "You must specify a Giant Bomb API key."

  @doc "Gets a list of games."
  @spec games(String.t, non_neg_integer) :: map_result
  def games(api_key, offset \\ 0)
  def games("", _), do: raise_api_key_error
  def games(nil, _), do: raise_api_key_error
  def games(api_key, offset) do
    opts = make_request_opts(api_key, offset: offset)

    ExGiantBomb.get!("/games/", [], opts).body
  end

  @doc "Gets a game's details."
  @spec game(String.t, game_id) :: map_result
  def game("", _), do: raise_api_key_error
  def game(nil, _), do: raise_api_key_error
  def game(api_key, id) do
    opts = make_request_opts(api_key)

    ExGiantBomb.get!("/game/#{id}/", [], opts).body
  end
end
