defmodule Blog.Posts do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Posts.Post

  @topic "posts"

  def subscribe do
    Phoenix.PubSub.subscribe(Blog.PubSub, @topic)
  end

  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.inserted_at])
  end

  def list_active_posts do
    Repo.all(
      from p in Post,
        where: p.status == :active,
        order_by: [desc: p.inserted_at],
        preload: [:user]
    )
  end

  def list_posts_by_status(status) do
    Repo.all(from p in Post, where: p.status == ^status, order_by: [desc: p.inserted_at])
  end

  def get_post!(id) do
    Repo.get!(Post, id) |> Repo.preload(:user)
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> broadcast(:post_updated)
  end

  def delete_post(%Post{} = post) do
    post
    |> Repo.delete()
    |> broadcast(:post_deleted)
  end

  defp broadcast({:ok, post} = result, event) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {event, post})
    result
  end

  defp broadcast({:error, _} = result, _event), do: result

  def list_all_posts do
    Repo.all(from p in Post,
      order_by: [desc: p.inserted_at],
      preload: [:user])
  end

  def update_post_status(%Post{} = post, status) do
    post
    |> Post.status_changeset(%{status: status})
    |> Repo.update()
    |> broadcast(:post_updated)
  end
end
