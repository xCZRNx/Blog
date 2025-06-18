defmodule Blog.Repo.Migrations.NewMigr do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_admin, :boolean, default: false
      add :is_blocked, :boolean, default: false
    end

    create table(:posts) do
      add :body, :text, null: false
      add :likes_count, :integer, default: 0
      add :status, :string, default: "active"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:comments) do
      add :body, :text, null: false
      add :likes_count, :integer, default: 0
      add :status, :string, default: "active"
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:comments, [:user_id])
    create index(:comments, [:post_id])
  end
end
