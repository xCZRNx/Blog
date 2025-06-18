defmodule Blog.Posts do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :likes_count, :integer, default: 0
    field :status, Ecto.Enum, values: [:active, :banned], default: :active
    field :body, :string
    belongs_to :user, Blog.Accounts.User
    has_many :comments, Blog.Comments
    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:likes_count, :status, :body, :user_id])
    |> validate_required([:body, :user_id])
  end
end
