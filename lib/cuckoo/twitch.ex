defmodule Cuckoo.Twitch do
    import HTTPoison
    import Poison

    def get_twitch_user(user_login) do
        client_id = Application.get_env(:cuckoo, :twitch_client_id)
        urls = Application.get_env(:cuckoo, :twitch_urls)
        # [client_id: clientId, urls: urls] = conf
        HTTPoison.get(urls[:users], ["Client-ID": client_id], params: [login: user_login])
        |> get_data
    end

    defp get_data({:error, %HTTPoison.Error{}}) do
        []
    end

    defp get_data({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
        body
        |> Poison.Parser.parse!
        |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
        |> Keyword.get(:data)
    end
end