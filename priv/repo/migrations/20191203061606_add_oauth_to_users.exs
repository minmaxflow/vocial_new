defmodule Vocial.Repo.Migrations.AddOauthToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :oauth_provider, :string
      add :oauth_id, :string
    end
  end
end
