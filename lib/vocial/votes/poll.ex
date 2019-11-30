defmodule Vocial.Votes.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.{Option, Poll}
  alias Vocial.Accounts.User

  schema "polls" do
    field :title, :string

    # defaults to the underscored name of the current schema suffixed by _id
    # 比如现在默认就是在Option表上有一个poll_id的外键
    # 可以通过 :foreign_key 来定制
    has_many :options, Option
    belongs_to :user, User

    timestamps()
  end

  def changeset(%Poll{} = poll, attrs) do
    poll
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
