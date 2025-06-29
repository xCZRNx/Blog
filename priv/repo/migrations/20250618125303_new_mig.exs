defmodule Blog.Repo.Migrations.NewMig do
  use Ecto.Migration

  def change do
    # Create posts table
    create table(:posts) do
      add :likes_count, :integer, default: 0, null: false
      add :status, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create index(:posts, [:user_id])

    # Create comments table
    create table(:comments) do
      add :likes_count, :integer, default: 0, null: false
      add :status, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :delete_all)
      timestamps()
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id])

    # Alter users table to add is_admin and is_blocked
    alter table(:users) do
      add :is_admin, :boolean, default: false, null: false
      add :is_blocked, :boolean, default: false, null: false
    end
  end
end
