defmodule Arbor.Folder do
  @moduledoc false
  use Ecto.Schema

  use Arbor.Tree,
    foreign_key: :parent_id,
    foreign_key_type: :binary_id

  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "folders" do
    field(:name, :string)
    belongs_to(:parent, Arbor.Folder)

    timestamps()
  end

  def by_inserted_at(query \\ __MODULE__) do
    from(
      f in query,
      order_by: [asc: :inserted_at]
    )
  end
end
