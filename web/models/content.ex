defmodule Cuckoo.Content do
  use Cuckoo.Web, :model

  schema "contents" do
    field :twitch_id, :string
    field :user_login, :string
    field :profile_image_url, :string
    field :start_template, :string
    field :hourly_template, :string
    field :activate, :boolean, default: true
    belongs_to :user, Cuckoo.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :twitch_id, :user_login, :profile_image_url, :start_template, :hourly_template, :activate])
  end
end
