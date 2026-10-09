defmodule Blog.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :string
      add :status, :string
      add :likes_count, :integer

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create table(:comments) do
      add :body, :string
      add :status, :string
      add :likes_count, :integer

      add :post_id, references(:posts, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    alter table(:users) do
      add :bio, :string
      add :is_admin, :boolean
      add :is_blocked, :boolean
    end
  end
end
