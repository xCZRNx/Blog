defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :status, Ecto.Enum, values: [:active, :banned], default: :active

    belongs_to :user, Blog.Accounts.User
    has_many :comments, Blog.Comments.Comment

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :likes_count, :status, :user_id])
    |> validate_required([:body, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  def status_changeset(post, attrs) do
    post
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
