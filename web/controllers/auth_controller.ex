defmodule Cuckoo.AuthController do
   use Cuckoo.Web, :controller
   
   alias Cuckoo.Router
   alias Cuckoo.User
   alias Cuckoo.Content

   def request(conn, _params) do
       token = ExTwitter.request_token(
           Router.Helpers.auth_url(conn, :callback)
       )
       {:ok, authorize_url} = ExTwitter.authorize_url(token.oauth_token)
       redirect conn, external: authorize_url
   end

   def callback(conn, %{"oauth_token" => oauth_token, "oauth_verifier" => oauth_verifier}) do

    {:ok, access_token} = ExTwitter.access_token(oauth_verifier, oauth_token)

    # if we just ran configure without merging in the existing
    # config, we would lose existing config
    ExTwitter.configure(
      :process,
      Enum.concat(
        ExTwitter.Config.get_tuples,
        [ access_token: access_token.oauth_token,
          access_token_secret: access_token.oauth_token_secret ]
      )
    )

    user_info = ExTwitter.verify_credentials()

    conn = conn
      |> put_session(:current_user, user_info)
      |> put_session(:access_token, access_token.oauth_token)
      |> put_session(:access_token_secret, access_token.oauth_token_secret)
    redirect conn, to: Router.Helpers.page_path(conn, :index)

  end

  def callback(conn, %{"denied" => _}) do
    conn
    |> put_flash(:error, "You did not give us access to your account")
    |> redirect(to: Router.Helpers.page_path(conn, :index))
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Router.Helpers.page_path(conn, :index))
  end
end