defmodule Arbor.Adapters.Postgres do
  @moduledoc """
  Postgres tree adapter
  """

  import Ecto.Query

  @doc """
  TODO: Support strings and structs
  TODO: Ensure composability
  """
  @spec roots(atom(), Keyword.t()) :: Ecto.Query.t()
  def roots(schema, opts \\ []) do
    # foreign_key = opts |> build_opts |> Keyword.get(:foreign_key)
    foreign_key = :parent_id
    from(t in schema, where: is_nil(field(t, ^foreign_key)))
  end

  defp build_opts(opts) do
    opts
  end
end
