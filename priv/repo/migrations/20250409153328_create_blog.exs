defmodule Blog.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def up do
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

  def down do
    drop_if_exists table(:comments_gpt)
    drop_if_exists table(:users_tokens)
    drop_if_exists table(:comments)
    drop_if_exists table(:posts_gpt)
    drop_if_exists table(:posts)
    drop_if_exists table(:users)
  end
end
