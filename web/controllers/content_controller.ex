defmodule Cuckoo.ContentController do
  use Cuckoo.Web, :controller

  import Cuckoo.Twitch

  alias Cuckoo.Router
  alias Cuckoo.Content
  alias Cuckoo.User

  def new(conn, _params) do
    changeset = Content.changeset(%Content{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"content" => content_params}) do
    twitter_id = conn |> get_session(:current_user) |> Map.get(:id) |> to_string
    access_token = conn |> get_session(:access_token)
    access_token_secret = conn |> get_session(:access_token_secret)

    user_login = content_params["user_login"]

    [twitch_user|_] = get_twitch_user(user_login)
    
    result = 
      case Repo.get_by(User, twitter_id: twitter_id) do 
        nil -> 
          %User{
            twitter_id: twitter_id, 
            access_token: access_token, 
            oauth_token_secret: access_token_secret,
          }
        user -> user
      end
      |> User.changeset
      |> Repo.insert_or_update

    twitch_user_map = %{
      "twitch_id" => twitch_user["id"],
      "profile_image_url" => twitch_user["profile_image_url"]
    }

    merged_map = Map.merge(content_params, twitch_user_map)

    changeset =
      Repo.get_by(User, twitter_id: twitter_id)
      |> build_assoc(:content)
      |> Content.changeset(merged_map)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully created.")
        |> redirect(to: Router.Helpers.page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)
    changeset = Content.changeset(content)
    render conn, "edit.html", content: content, changeset: changeset
  end

  def update(conn, %{"id" => id, "content" => content_params}) do

    content = Repo.get!(Content, id)
    changeset = Content.changeset(content, content_params)

    twitch_user = get_twitch_user(content_params["user_login"])

    case Repo.update(changeset) do
      {:ok, content} ->
        conn
        |> put_flash(:info, "Successfully updated.")
        |> redirect(to: content_path(conn, :edit, content.id))
      {:error, changeset} ->
        render(conn, "edit.html", content: content, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    content = Repo.get!(Content, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(content)

    conn
    |> put_flash(:info, "Successfully deleted.")
    |> redirect(to: Router.Helpers.page_path(conn, :index))
  end
end
