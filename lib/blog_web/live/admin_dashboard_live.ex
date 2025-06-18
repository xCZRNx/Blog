defmodule BlogWeb.AdminDashboardLive do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    if user.is_admin do
      posts = Posts.list_posts()
      {:ok, assign(socket, posts: posts)}
    else
      {:ok,
       socket
       |> put_flash(:error, "You are not authorized to access the admin dashboard.")
       |> push_navigate(to: "/blog")}
    end
  end

  @impl true
  def handle_event("change_status", %{"post_id" => id, "new_status" => status}, socket) do
    post = Posts.get_post!(id)
    # Convert status string to atom if needed
    status_atom = if is_atom(status), do: status, else: String.to_existing_atom(status)
    case Posts.update_post(post, %{status: status_atom}) do
      {:ok, _updated_post} ->
        {:noreply, assign(socket, posts: Posts.list_posts())}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update post status.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Admin Dashboard - Manage Posts</h1>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Body</th>
            <th>Status</th>
            <th>Likes</th>
            <th>Change Status</th>
          </tr>
        </thead>
        <tbody>
        <%= for post <- @posts do %>
          <tr id={"post-#{post.id}"}>
            <td><%= post.id %></td>
            <td><%= post.body %></td>
            <td><%= post.status %></td>
            <td><%= post.likes_count %></td>
            <td>
              <form phx-submit="change_status">
                <input type="hidden" name="post_id" value={post.id} />
                <select name="new_status">
                  <option value="active" selected={post.status == :active}>active</option>
                  <option value="banned" selected={post.status == :banned}>banned</option>
                </select>
                <button type="submit">Update</button>
              </form>
            </td>
          </tr>
        <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
