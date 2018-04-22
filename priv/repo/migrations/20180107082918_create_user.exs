defmodule Cuckoo.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :twitter_id, :string
      add :access_token, :string
      add :oauth_token_secret, :string
      
      timestamps()
    end
  end
end
