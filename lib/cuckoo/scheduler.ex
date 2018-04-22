defmodule Cuckoo.Scheduler do
    use Quantum.Scheduler , otp_app: :cuckoo

    import HTTPoison
    import Poison
    import Temp
    import Logger

    alias Cuckoo.Repo
    alias Cuckoo.User
    alias Cuckoo.Content

    def test do
        User
        |> Repo.all
        |> tweet_all
    end

    defp tweet_all([]) do
        Logger.info("all jobs have done")
    end

    defp tweet_all([head|tail]) do
        user = head
        |> Repo.preload(:content)
        |> get_stream
        |> convert

        tweet_all(tail)
    end

    defp get_stream(user) do
        [client_id: clientId, streams: streams] = Cuckoo.Scheduler.config[:twitch]
        
        data = HTTPoison.get(streams,["Client-ID": clientId], params: [user_login: user.content.user_login, type: "live"]) |> get_data_from_stream
        # data = HTTPoison.get(streams,["Client-ID": clientId], params: [user_login: "stylishnoob4", type: "live"]) |> get_data_from_stream
        # data = body |> get_data_from_stream
        {user, data}
    end

    defp get_data_from_stream({:error, %HTTPoison.Error{}}) do
        []
    end

    defp get_data_from_stream({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
        body
        |> Poison.Parser.parse!
        |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
        |> Keyword.get(:data)
    end

    defp convert({user, []}) do
        Logger.info("userId: #{user.id} is offline, skip tweet")
    end

    defp convert({user, [head|tail]}) do
        %User{
            id: userId,
            content: %Content{
                user_login: userLogin,
                start_template: start_template,
                hourly_template: hourly_template
            }
        } = user

        %{
            "started_at" => started_at,
            "title" => title,
            "thumbnail_url" => thumbnail_url 
        } = head

        now = DateTime.utc_now
        {:ok, started_at_dt, 0} = DateTime.from_iso8601(started_at)

        uptime = DateTime.diff(now, started_at_dt)

        hour = div(uptime, 3600)
        
        status = hourly_template
        |> String.replace("{title}", title)
        |> String.replace("{url}", "https://www.twitch.tv/" <> userLogin)
        
        status = case hour do
            0 -> String.replace(status, ~r/\{uptime\}\(.*?\)/, "") |> String.replace("{start}(", "") |> String.replace(")", "")
            _ -> String.replace(status, ~r/\{start\}\(.*?\)/, "") |> String.replace("{uptime}(", "") |> String.replace(")", "") |> String.replace("{h}", Integer.to_string(hour))
        end
    
        Logger.info(status)
        {:ok, dir_path} = Temp.mkdir "tmp"
        
        url = thumbnail_url |> String.replace("{width}", "1280") |> String.replace("{height}", "720")
        file_name = String.split(url, "/") |> List.last

        HTTPoison.get(url)
        |> case do
            {:ok, res} -> File.write Path.join(dir_path, file_name), res.body, [:raw]
            {:error, res} -> nil
        end
        
        if rem(uptime, 3600) < 300 do
            image = File.read!(Path.join(dir_path, file_name))
            tweet(user, status, image)
        end
        
        File.rm_rf dir_path 
    end
    
    defp tweet(user, status, media) when media == nil do
        ExTwitter.configure(
            :process,
            Enum.concat(
              ExTwitter.Config.get_tuples,
              [ access_token: user.access_token,
                access_token_secret: user.oauth_token_secret ]
            )
          )
        IO.inspect ExTwitter.update(status)
    end

    defp tweet(user, status, media) when media != nil do
        ExTwitter.configure(
            :process,
            Enum.concat(
              ExTwitter.Config.get_tuples,
              [ access_token: user.access_token,
                access_token_secret: user.oauth_token_secret ]
            )
          )
        IO.inspect ExTwitter.update_with_media(status, media)
    end
end