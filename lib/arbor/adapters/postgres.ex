defmodule Arbor.Adapters.Postgres do
  @moduledoc """
  Postgres tree adapter
  """

  import Ecto.Query

  @doc """
  Query for root level records.

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

  @doc """
  Query for a child record's parent.

  ## Examples
  TODO: Add examples
  """
  @spec parent(struct(), Keyword.t()) :: Ecto.Query.t()
  def parent(%{__meta__: meta} = child_struct, opts \\ []) do
    schema = meta.schema
    defaults = schema_defaults(schema)
    merged_opts = Keyword.merge(defaults, opts)

    primary_key = merged_opts[:primary_key]
    foreign_key = merged_opts[:foreign_key]
    foreign_key_type = merged_opts[:foreign_key_type]
    foreign_key_value = Map.get(child_struct, foreign_key)

    from(
      t in schema,
      where: field(t, ^primary_key) == type(^foreign_key_value, ^foreign_key_type)
    )
  end

  # Generates defaults to be merged with opts given an ecto schema
  defp schema_defaults(module) do
    primary_key = :primary_key |> module.__schema__() |> List.first()
    primary_key_type = module.__schema__(:type, primary_key)

    [
      primary_key: primary_key,
      primary_key_type: primary_key_type,
      foreign_key: :parent_id,
      foreign_key_type: primary_key_type
    ]
  end
end
