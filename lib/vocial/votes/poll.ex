defmodule Vocial.Votes.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.{Option, Poll}

  schema "polls" do
    field :title, :string

    # defaults to the underscored name of the current schema suffixed by _id
    # 比如现在默认就是在Option表上有一个poll_id的外键
    # 可以通过 :foreign_key 来定制
    has_many :options, Option
    timestamps()
  end

  def changeset(%Poll{} = poll, attrs) do
    poll
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
