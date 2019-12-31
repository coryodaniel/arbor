defmodule Arbor.Adapters.Postgres do
  @moduledoc """
  Postgres tree adapter
  """

  import Ecto.Query

  @doc """
  ## Examples
    Basic Usage:
      iex> Arbor.Adapters.Postgres.roots(Arbor.Comment)
      #Ecto.Query<from c0 in Arbor.Comment, where: is_nil(c0.parent_id)>

    Providing parent foreign key name:
      iex> Arbor.Adapters.Postgres.roots(Arbor.Folder, foreign_key: :parent_uuid)
      #Ecto.Query<from c0 in Arbor.Comment, where: is_nil(c0.parent_id)>

    Ad-hoc queries:
      iex> Arbor.Adapters.Postgres.roots("comments")
      #Ecto.Query<from c0 in "comments", where: is_nil(c0.parent_id)>

    Composing queries:
      iex> roots = Arbor.Adapters.Postgres.roots(Arbor.Comment)
      ...> sorted_roots = Arbor.Comment.by_inserted_at(roots)
      #Ecto.Query<from c0 in Arbor.Comment, where: is_nil(c0.parent_id), order_by: [asc: c0.inserted_at]>
  """
  @spec roots(module() | String.t(), Keyword.t()) :: Ecto.Query.t()
  def roots(schema, opts \\ []) do
    foreign_key = Keyword.get(opts, :foreign_key, :parent_id)
    from(t in schema, where: is_nil(field(t, ^foreign_key)))
  end
end
