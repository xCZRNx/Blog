defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  alias Blog.ContentManager
  alias Blog.Posts

  def mount(_params, _session, socket) do
    if connected?(socket), do: BlogWeb.Endpoint.subscribe("posts")
    posts = ContentManager.list_active_posts()
    changeset = Posts.changeset(%Posts{}, %{})
    {:ok, assign(socket, posts: posts, show_modal: false, changeset: changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Blog Main Page</h1>
      <button phx-click="toggle_modal">Create New Post</button>
      <%= if @show_modal do %>
        <div class="modal">
          <form phx-submit="save_post">
            <textarea name="post[body]" placeholder="Enter post content"></textarea>
            <button type="submit">Save Post</button>
          </form>
          <button phx-click="toggle_modal">Close</button>
        </div>
      <% end %>
      <div id="posts">
        <%= for post <- @posts do %>
          <div id={"post-#{post.id}"}>
            <p>
              <%= post.body %>
              <a href={Routes.post_live_show_path(@socket, :show, post.id)}>View Post</a>
            </p>
            <p>Likes: <%= post.likes_count %></p>
            <button phx-click="like_post" phx-value-id={post.id}>Like</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  def handle_event("save_post", %{"post" => post_params}, socket) do
    # Replace 1 with current user id as needed.
    case ContentManager.create_post(Map.put(post_params, "user_id", 1)) do
      {:ok, post} ->
        {:noreply, assign(socket, show_modal: false, posts: [post | socket.assigns.posts])}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("like_post", %{"id" => id}, socket) do
    post = ContentManager.get_post!(id)
    new_likes = post.likes_count + 1
    {:ok, updated_post} = ContentManager.update_post(post, %{"likes_count" => new_likes})
    posts = Enum.map(socket.assigns.posts, fn p -> if p.id == updated_post.id, do: updated_post, else: p end)
    {:noreply, assign(socket, posts: posts)}
  end

  def handle_info(%{event: "post_created", payload: post}, socket) do
    if Enum.any?(socket.assigns.posts, fn p -> p.id == post.id end) do
      {:noreply, socket}
    else
      {:noreply, assign(socket, posts: [post | socket.assigns.posts])}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
