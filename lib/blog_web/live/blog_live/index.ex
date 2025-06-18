defmodule BlogWeb.BlogLive.Index do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe_posts()
    posts = Posts.list_active_posts()
    {:ok,
     assign(socket,
       posts: posts,
       show_modal: false,
       changeset: Posts.Post.changeset(%Post{}, %{})
     )}
  end

  @impl true
  def handle_event("show_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, changeset: Posts.Post.changeset(%Post{}, %{}))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    user_id = socket.assigns.current_user.id
    attrs = Map.put(post_params, "user_id", user_id)
    case Posts.create_post(attrs) do
      {:ok, _post} ->
        {:noreply, assign(socket, show_modal: false, changeset: Posts.Post.changeset(%Post{}, %{}))}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("like", %{"id" => id}, socket) do
    post = Posts.get_post!(id)
    Posts.update_post(post, %{likes_count: post.likes_count + 1})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:created, %Post{} = post}, socket) do
    if post.status == :active do
      {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
    else
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Blog Posts</h1>
      <button phx-click="show_modal">Create New Post</button>
      <%= if @show_modal do %>
        <div class="modal">
          <div class="modal-content">
            <h2>New Post</h2>
            <.form let={f} for={@changeset} phx-submit="save">
              <%= textarea f, :body, placeholder: "Write your post...", required: true %>
              <%= hidden_input f, :status, value: "active" %>
              <div>
                <button type="submit">Submit</button>
                <button type="button" phx-click="hide_modal">Cancel</button>
              </div>
              <%= for {attr, msg} <- @changeset.errors do %>
                <div class="error"><%= "#{attr}: #{msg}" %></div>
              <% end %>
            </.form>
          </div>
        </div>
      <% end %>
      <ul>
        <%= for post <- @posts do %>
          <li id={"post-#{post.id}"}>
            <div>
              <strong>
                <.link navigate={~p"/blog/posts/#{post.id}"}>Post #<%= post.id %></.link>
              </strong>
              <p><%= post.body %></p>
              <span>Likes: <%= post.likes_count %></span>
              <button phx-click="like" phx-value-id={post.id}>Like</button>
            </div>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
