defmodule Arbor.Comment do
  @moduledoc false
  use Ecto.Schema

  use Arbor.Tree,
    foreign_key: :parent_id,
    foreign_key_type: :integer

  import Ecto.Query

  schema "comments" do
    field(:body, :string)
    belongs_to(:parent, Arbor.Comment)

    timestamps()
  end

  def by_inserted_at(query \\ __MODULE__) do
    from(
      c in query,
      order_by: [asc: :inserted_at]
    )
  end
end
