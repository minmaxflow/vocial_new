defmodule Vocial.AccountsTest do
  use Vocial.DataCase

  alias Vocial.Accounts

  describe "users" do
    @valid_attrs %{
      username: "test",
      email: "test@test.com",
      active: true,
      password: "test",
      password_confirmation: "test"
    }

    def user_fixture(attrs \\ %{}) do
      with create_attrs <- Map.merge(@valid_attrs, attrs),
           {:ok, user} <- Accounts.create_user(create_attrs) do
        user |> Map.merge(%{password: nil, password_confirmation: nil})
      end
    end

    test "list_user/o return all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user/1 returns the user with the id" do
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "new_user/0 returns a blank changeset" do
      changeset = Accounts.new_user()

      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_user/1 creates the user in the db and returns it" do
      before = Accounts.list_users()
      user = user_fixture()
      updated = Accounts.list_users()
      assert !Enum.any?(before, fn u -> u == user end)
      assert Enum.any?(updated, fn u -> u == user end)
    end

    test "create_user/1 password problem 1" do
      {:error, changeset} = user_fixture(%{password: nil, password_confirmation: nil})
      assert !changeset.valid?
    end

    test "create_user/1 password problme 2" do
      {:error, changeset} = user_fixture(%{password: "aa", password_confirmation: "bb"})
      assert !changeset.valid?
    end

    test "get_user_by_username/1" do
      user = user_fixture()
      assert Accounts.get_user_by_username(user.username)
    end

    test "get_user_by_username/1 failed" do
      assert is_nil(Accounts.get_user_by_username("fail"))
    end
  end
end
