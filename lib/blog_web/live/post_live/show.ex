defmodule BlogWeb.PostLive.Show do
  use BlogWeb, :live_view

  alias Blog.ContentManager
  alias Blog.Comments
  alias Blog.Posts

  def mount(%{"id" => post_id}, _session, socket) do
    if connected?(socket), do: BlogWeb.Endpoint.subscribe("comments")
    post = ContentManager.get_post!(post_id)
    comments = ContentManager.list_comments_for_post(post.id)
    changeset = Comments.changeset(%Comments{}, %{})
    {:ok, assign(socket, post: post, comments: comments, show_comment_modal: false, comment_changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Post Details</h1>
      <div id="post-details">
        <p><%= @post.body %></p>
        <p>Likes: <%= @post.likes_count %></p>
      </div>
      <section id="comments">
        <h2>Comments</h2>
        <button phx-click="toggle_comment_modal">New Comment</button>
        <%= if @show_comment_modal do %>
          <div class="modal">
            <form phx-submit="save_comment">
              <textarea name="comment[body]" placeholder="Enter comment"></textarea>
              <button type="submit">Save Comment</button>
            </form>
            <button phx-click="toggle_comment_modal">Close</button>
          </div>
        <% end %>
        <%= for comment <- @comments do %>
          <div id={"comment-#{comment.id}"}>
            <p><%= comment.body %></p>
            <p>Likes: <%= comment.likes_count %></p>
            <button phx-click="like_comment" phx-value-id={comment.id}>Like</button>
          </div>
        <% end %>
      </section>
    </div>
    """
  end

  def handle_event("toggle_comment_modal", _params, socket) do
    {:noreply, assign(socket, show_comment_modal: !socket.assigns.show_comment_modal)}
  end

  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    # Replace 1 with current user id if available.
    params = Map.put(comment_params, "user_id", 1)
             |> Map.put("post_id", socket.assigns.post.id)
    case ContentManager.create_comment(params) do
      {:ok, comment} ->
        {:noreply, assign(socket, show_comment_modal: false, comments: [comment | socket.assigns.comments])}
      {:error, changeset} ->
        {:noreply, assign(socket, comment_changeset: changeset)}
    end
  end

  def handle_event("like_comment", %{"id" => id}, socket) do
    comment = ContentManager.get_comment!(id)
    new_likes = comment.likes_count + 1
    {:ok, updated_comment} = ContentManager.update_comment(comment, %{"likes_count" => new_likes})
    comments = Enum.map(socket.assigns.comments, fn c -> if c.id == updated_comment.id, do: updated_comment, else: c end)
    {:noreply, assign(socket, comments: comments)}
  end

  def handle_info(%{event: "comment_created", payload: comment}, socket) do
    if comment.post_id == socket.assigns.post.id and
         not Enum.any?(socket.assigns.comments, fn c -> c.id == comment.id end) do
      {:noreply, assign(socket, comments: [comment | socket.assigns.comments])}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
