defmodule Blog.Comments do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :likes_count, :integer, default: 0
    field :status, Ecto.Enum, values: [:active, :banned], default: :active
    field :body, :string
    belongs_to :user, Blog.Accounts.User
    belongs_to :post, Blog.Posts
    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:likes_count, :status, :body, :user_id, :post_id])
    |> validate_required([:body, :user_id, :post_id])
  end
end
