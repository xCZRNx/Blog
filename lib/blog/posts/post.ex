defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :status, Ecto.Enum, values: [:active, :banned]
    field :likes_count, :integer, default: 0

    belongs_to :user, Blog.Accounts.User
    has_many :comments, Blog.Posts.Comment

    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:body, :status, :user_id])
    |> validate_required([:body, :status, :user_id])
  end

  def likes_count_changeset(post, attrs) do
    post
    |> cast(attrs, [:likes_count])
    |> validate_required([:likes_count])
  end

end
