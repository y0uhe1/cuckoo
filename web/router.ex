defmodule Cuckoo.Router do
  use Cuckoo.Web, :router

  alias Cuckoo.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.AssignCurrentUser
    plug Plugs.ConfigureTwitterClient
  end

  scope "/", Cuckoo do
    pipe_through :browser
    
    get "/auth/request", AuthController, :request
    get "/auth/callback", AuthController, :callback
    get "/auth/logout", AuthController, :logout
    
    get "/", PageController, :index
    resources "/contents", ContentController
  end
  # Other scopes may use custom stacks.
  # scope "/api", Cuckoo do
  #   pipe_through :api
  # end
end
