defmodule Vocial.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :username, :string
      add :email, :string
      add :encrypted_password, :string
      add :active, :boolean, default: true
      timestamps()
    end
  end
end
