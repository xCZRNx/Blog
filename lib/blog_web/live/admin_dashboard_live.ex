defmodule BlogWeb.AdminDashboardLive do
  use BlogWeb, :live_view

  alias Blog.ContentManager

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user || %{}
    if !Map.get(current_user, :is_admin, false) do
      {:halt, push_redirect(socket, to: Routes.post_live_index_path(socket, :index))}
    else
      posts = ContentManager.list_posts()
      {:ok, assign(socket, posts: posts)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Admin Dashboard</h1>
      <%= for post <- @posts do %>
        <div id={"post-#{post.id}"}>
          <p><%= post.body %></p>
          <p>Likes: <%= post.likes_count %></p>
          <p>Status: <%= post.status %></p>
          <select phx-change="update_status" phx-value-id={post.id}>
            <option value="active" selected={post.status == :active}>Active</option>
            <option value="banned" selected={post.status == :banned}>Banned</option>
          </select>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "value" => new_status}, socket) do
    post = ContentManager.get_post!(id)
    case ContentManager.update_post(post, %{"status" => new_status}) do
      {:ok, updated_post} ->
        posts = Enum.map(socket.assigns.posts, fn p -> if p.id == updated_post.id, do: updated_post, else: p end)
        {:noreply, assign(socket, posts: posts)}
      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
