defmodule Cuckoo.User do
    use Cuckoo.Web, :model

    schema "users" do
        field :twitter_id, :string
        field :access_token, :string
        field :oauth_token_secret, :string
        has_many :content, Cuckoo.Content

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:twitter_id, :access_token, :oauth_token_secret])
        |> validate_required([:twitter_id, :access_token, :oauth_token_secret])
    end
end