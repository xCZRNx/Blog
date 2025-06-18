defmodule BlogWeb.BlogLive.Show do
  use BlogWeb, :live_view

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Comments.Comment

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Posts.subscribe_comments()
    post = Posts.get_post!(id)
    comments = Posts.list_comments_for_post(post.id)
    {:ok,
     assign(socket,
       post: post,
       comments: comments,
       show_modal: false,
       changeset: Comment.changeset(%Comment{}, %{})
     )}
  end

  @impl true
  def handle_event("show_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, changeset: Comment.changeset(%Comment{}, %{}))}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    user_id = socket.assigns.current_user.id
    attrs =
      comment_params
      |> Map.put("user_id", user_id)
      |> Map.put("post_id", socket.assigns.post.id)
      |> Map.put("status", "active")

    case Posts.create_comment(attrs) do
      {:ok, _comment} ->
        {:noreply, assign(socket, show_modal: false, changeset: Comment.changeset(%Comment{}, %{}))}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info({:created, %Comment{} = comment}, socket) do
    if comment.post_id == socket.assigns.post.id and comment.status == :active do
      {:noreply, update(socket, :comments, fn comments -> [comment | comments] end)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Post #<%= @post.id %></h2>
      <p><%= @post.body %></p>
      <span>Likes: <%= @post.likes_count %></span>
      <hr/>
      <h3>Comments</h3>
      <button phx-click="show_modal">Add Comment</button>
      <%= if @show_modal do %>
        <div class="modal">
          <div class="modal-content">
            <h4>New Comment</h4>
            <.form for={@changeset} as={:comment} phx-submit="save">
              <.input field={:body} type="textarea" placeholder="Write your comment..." required />
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
        <%= for comment <- @comments do %>
          <li id={"comment-#{comment.id}"}>
            <p><%= comment.body %></p>
            <span>Likes: <%= comment.likes_count %></span>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
