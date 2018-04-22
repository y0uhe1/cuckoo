defmodule Cuckoo.PageController do
    use Cuckoo.Web, :controller

    alias Cuckoo.User
    alias Cuckoo.Content

    def index(conn, _param) do
        if conn.assigns.current_user do
            %{ :id => user_id } = conn.assigns.current_user

            content = 
            case Repo.get_by(User, twitter_id: to_string(user_id)) |> Repo.preload(:content) do
                %User{:content => content} -> content
                nil -> []
            end

            IO.inspect content

            render conn, "logged_in.html", contents: content
        else
            render conn, "logged_out.html"
        end
    end
end