defmodule TestRepo.Migrations.CreateFoldersAndComments do
  use Ecto.Migration

  def change do
    execute ~S(CREATE EXTENSION IF NOT EXISTS "uuid-ossp")
    create table(:comments) do
      add :body, :string
      add :parent_id, references(:comments), null: true

      timestamps()
    end
    create index(:comments, [:parent_id])

    create table(:folders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :parent_id, references(:folders, type: :binary_id), null: true

      timestamps()
    end
    create index(:folders, [:parent_id])

    create table(:foreigns, primary_key: false) do
      add :uuid, :binary_id, primary_key: true
      add :name, :string
      add :parent_uuid, references(:foreigns, type: :binary_id, column: :uuid), null: true

      timestamps()
    end
    create index(:foreigns, [:parent_uuid])

    execute(
      """
      CREATE SCHEMA private
      """,
      """
      DROP SCHEMA private
      """
    )

    execute(
      """
      CREATE VIEW private.comments AS SELECT * from comments WHERE id = -1
      """,
      """
      DROP VIEW private.comments
      """
    )
  end
end
