defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.{Post, Comment}

  ## Posts

  @doc """
  Lists all posts.
  """
  def list_posts do
    Post
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:user, :comments])
  end

  def list_active_posts() do
    from(p in Post,
      where: p.status == :active,
      order_by: [desc: :inserted_at],
      preload: [:user, :comments]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.
  """

  def create_post(attrs \\ %{}) do
    attrs
    |> Post.changeset()
    |> Repo.insert()
    |> case do
      {:ok, post} ->
        BlogWeb.Endpoint.broadcast("posts", "new-post", post)
        {:ok, post}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a post.
  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.
  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking post changes.
  # """
  # def change_post(%Post{} = post, attrs \\ %{}) do
  #   Post.changeset(post, attrs)
  # end

  @doc """
  Increments the likes count for a post.
  """
  def increment_post_likes(%Post{} = post) do
    post
    |> Post.likes_count_changeset(%{likes_count: post.likes_count + 1})
    |> Repo.update()
    |> case do
      {:ok, updated_post} ->
        BlogWeb.Endpoint.broadcast("posts", "update-post", updated_post)
        {:ok, updated_post}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  ## Comments

  @doc """
  Lists all comments for a given post.
  """
  def list_comments(post_id) do
    Comment
    |> where(post_id: ^post_id)
    |> Repo.all()
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.
  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.
  """
  def create_comment(attrs \\ %{}) do
    attrs
    |> Comment.changeset()
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        BlogWeb.Endpoint.broadcast("comment", "new-comment", comment)
        {:ok, comment}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # @doc """
  # Updates a comment.
  # """
  # def update_comment(%Comment{} = comment, attrs) do
  #   comment
  #   |> Comment.changeset(attrs)
  #   |> Repo.update()
  # end

  @doc """
  Deletes a comment.
  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking comment changes.
  # """
  # def change_comment(%Comment{} = comment, attrs \\ %{}) do
  #   Comment.changeset(comment, attrs)
  # end

  @doc """
  Increments the likes count for a comment.
  """
  def increment_comment_likes(%Comment{} = comment) do
    comment
    |> Comment.likes_count_changeset(%{likes_count: comment.likes_count + 1})
    |> Repo.update()
  end
end
