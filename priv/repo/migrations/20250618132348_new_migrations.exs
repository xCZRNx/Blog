defmodule Blog.Repo.Migrations.NewMigrations do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :likes_count, :integer, default: 0
      add :status, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create table(:comments) do
      add :likes_count, :integer, default: 0
      add :status, :string
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end

    alter table(:users) do
      add :is_admin, :boolean, default: false
      add :is_blocked, :boolean, default: false
    end
  end
end
