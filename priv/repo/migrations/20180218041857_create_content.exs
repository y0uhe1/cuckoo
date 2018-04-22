defmodule Cuckoo.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:contents) do
      add :twitch_id, :string
      add :user_login, :string
      add :profile_image_url, :string
      add :start_template, :string
      add :hourly_template, :string
      add :activate, :boolean, default: true

      timestamps()
    end
  end
end
