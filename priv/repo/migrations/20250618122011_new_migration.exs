defmodule Blog.Repo.Migrations.NewMigration do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :likes_count, :integer, default: 0, null: false
      add :status, :string, null: false
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:user_id])

    create table(:comments) do
      add :likes_count, :integer, default: 0, null: false
      add :status, :string, null: false
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id])

    alter table(:users) do
      add :is_admin, :boolean, default: false, null: false
      add :is_blocked, :boolean, default: false, null: false
    end
  end
end
