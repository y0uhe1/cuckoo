defmodule Cuckoo.StateTest do
  use Cuckoo.ModelCase

  alias Cuckoo.State

  @valid_attrs %{is_use_preview: true, tags: [], template: "some content", user_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = State.changeset(%State{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = State.changeset(%State{}, @invalid_attrs)
    refute changeset.valid?
  end
end
