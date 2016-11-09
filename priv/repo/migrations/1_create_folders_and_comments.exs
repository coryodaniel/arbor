defmodule TestRepo.Migrations.CreateFoldersAndComments do
  use Ecto.Migration

  def change do
    execute ~S(CREATE EXTENSION IF NOT EXISTS "uuid-ossp")
    create table(:comments) do
      add :body, :string
      add :parent_id, references(:comments), null: true

      timestamps
    end
    # create index(:comments, [:parent_id])

    create table(:folders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :parent_id, references(:folders, type: :binary_id), null: true

      timestamps
    end
    # create index(:folders, [:parent_id])
  end
end
