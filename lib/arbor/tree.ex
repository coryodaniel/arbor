defmodule Arbor.Tree do
  @moduledoc """

  Using `Arbor.Tree` will add common tree traversal functions to your Ecto model.

  ## Examples
      defmodule Comment do
        use Ecto.Schema
        use Arbor.Tree,
          table_name: "comments",
          tree_name: "comments_tree",
          primary_key: :id,
          primary_key_type: :id,
          foreign_key: :parent_id,
          foreign_key_type: :id
          orphan_strategy: :nothing

        schema "comments" do
          field :body, :string
          belongs_to :parent, Arbor.Comment

          timestamps()
        end
      end
  """

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      @arbor_opts unquote(opts)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: definition} = _env) do
    arbor_opts = Module.get_attribute(definition, :arbor_opts)

    {primary_key, primary_key_type, _} = Module.get_attribute(definition, :primary_key)
    struct_fields = Module.get_attribute(definition, :struct_fields)

    source =
      case struct_fields[:__meta__].source do
        {_, source} -> source
        source -> source
      end

    array_type =
      case primary_key_type do
        :binary_id -> "UUID"
        :id -> "integer"
        _ -> "string"
      end

    default_opts = [
      table_name: source,
      tree_name: "#{source}_tree",
      primary_key: primary_key,
      primary_key_type: primary_key_type,
      foreign_key: :parent_id,
      foreign_key_type: primary_key_type,
      array_type: array_type,
      orphan_strategy: :nothing,
      prefixes: []
    ]

    opts = Keyword.merge(default_opts, arbor_opts)

    roots =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def roots(unquote(prefix)) do
            from(
              t in unquote(definition),
              prefix: unquote(prefix),
              where: fragment(unquote("#{opts[:foreign_key]} IS NULL"))
            )
          end
        end
      end)

    parent =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def parent(%{__meta__: %{prefix: unquote(prefix)}} = struct) do
            from(
              t in unquote(definition),
              prefix: unquote(prefix),
              where:
                fragment(
                  unquote("#{opts[:primary_key]} = ?"),
                  type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type]))
                )
            )
          end
        end
      end)

    children =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def children(%{__meta__: %{prefix: unquote(prefix)}} = struct) do
            from(
              t in unquote(definition),
              prefix: unquote(prefix),
              where:
                fragment(
                  unquote("#{opts[:foreign_key]} = ?"),
                  type(^struct.unquote(opts[:primary_key]), unquote(opts[:foreign_key_type]))
                )
            )
          end
        end
      end)

    siblings =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def siblings(%{__meta__: %{prefix: unquote(prefix)}} = struct) do
            from(
              t in unquote(definition),
              prefix: unquote(prefix),
              where:
                t.unquote(opts[:primary_key]) !=
                  type(^struct.unquote(opts[:primary_key]), unquote(opts[:primary_key_type])),
              where:
                fragment(
                  unquote("#{opts[:foreign_key]} = ?"),
                  type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type]))
                )
            )
          end
        end
      end)

    ancestors =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def ancestors(%{__meta__: %{prefix: unquote(prefix)}} = struct) do
            from(t in unquote(definition),
              join:
                g in fragment(
                  unquote("""
                    (
                      WITH RECURSIVE #{opts[:tree_name]} AS (
                        SELECT #{opts[:primary_key]},
                              #{opts[:foreign_key]},
                              0 AS depth
                        FROM #{prefix}.#{opts[:table_name]}
                        WHERE #{opts[:primary_key]} = ?
                      UNION ALL
                        SELECT #{opts[:table_name]}.#{opts[:primary_key]},
                              #{opts[:table_name]}.#{opts[:foreign_key]},
                              #{opts[:tree_name]}.depth + 1
                        FROM #{prefix}.#{opts[:table_name]}
                          JOIN #{opts[:tree_name]}
                          ON #{opts[:tree_name]}.#{opts[:foreign_key]} = #{opts[:table_name]}.#{
                    opts[:primary_key]
                  }
                      )
                      SELECT *
                      FROM #{opts[:tree_name]}
                    )
                  """),
                  type(^struct.unquote(opts[:primary_key]), unquote(opts[:primary_key_type]))
                ),
              on: t.unquote(opts[:primary_key]) == g.unquote(opts[:foreign_key])
            )
          end
        end
      end)

    descendants =
      Enum.map(opts[:prefixes], fn prefix ->
        quote do
          def descendants(%{__meta__: %{prefix: unquote(prefix)}} = struct, depth) do
            from(
              t in unquote(definition),
              where:
                t.unquote(opts[:primary_key]) in fragment(
                  unquote("""
                    WITH RECURSIVE #{opts[:tree_name]} AS (
                      SELECT #{opts[:primary_key]},
                            0 AS depth
                      FROM #{prefix}.#{opts[:table_name]}
                      WHERE #{opts[:foreign_key]} = ?
                    UNION ALL
                      SELECT #{opts[:table_name]}.#{opts[:primary_key]},
                            #{opts[:tree_name]}.depth + 1
                      FROM #{prefix}.#{opts[:table_name]}
                        JOIN #{opts[:tree_name]}
                        ON #{opts[:table_name]}.#{opts[:foreign_key]} = #{opts[:tree_name]}.#{
                    opts[:primary_key]
                  }
                      WHERE #{opts[:tree_name]}.depth + 1 < ?
                    )
                    SELECT #{opts[:primary_key]} FROM #{opts[:tree_name]}
                  """),
                  type(^struct.unquote(opts[:primary_key]), unquote(opts[:foreign_key_type])),
                  type(^depth, :integer)
                )
            )
          end
        end
      end)

    quote do
      import Ecto.Query

      unquote(roots)

      def roots do
        from(
          t in unquote(definition),
          where: fragment(unquote("#{opts[:foreign_key]} IS NULL"))
        )
      end

      unquote(parent)

      def parent(struct) do
        from(
          t in unquote(definition),
          where:
            fragment(
              unquote("#{opts[:primary_key]} = ?"),
              type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type]))
            )
        )
      end

      unquote(children)

      def children(struct) do
        from(
          t in unquote(definition),
          where:
            fragment(
              unquote("#{opts[:foreign_key]} = ?"),
              type(^struct.unquote(opts[:primary_key]), unquote(opts[:foreign_key_type]))
            )
        )
      end

      unquote(siblings)

      def siblings(struct) do
        from(
          t in unquote(definition),
          where:
            t.unquote(opts[:primary_key]) !=
              type(^struct.unquote(opts[:primary_key]), unquote(opts[:primary_key_type])),
          where:
            fragment(
              unquote("#{opts[:foreign_key]} = ?"),
              type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type]))
            )
        )
      end

      unquote(ancestors)

      def ancestors(struct) do
        from(t in unquote(definition),
          join:
            g in fragment(
              unquote("""
              (
                WITH RECURSIVE #{opts[:tree_name]} AS (
                  SELECT #{opts[:primary_key]},
                        #{opts[:foreign_key]},
                        0 AS depth
                  FROM #{opts[:table_name]}
                  WHERE #{opts[:primary_key]} = ?
                UNION ALL
                  SELECT #{opts[:table_name]}.#{opts[:primary_key]},
                        #{opts[:table_name]}.#{opts[:foreign_key]},
                        #{opts[:tree_name]}.depth + 1
                  FROM #{opts[:table_name]}
                    JOIN #{opts[:tree_name]}
                    ON #{opts[:tree_name]}.#{opts[:foreign_key]} = #{opts[:table_name]}.#{
                opts[:primary_key]
              }
                )
                SELECT *
                FROM #{opts[:tree_name]}
              )
              """),
              type(^struct.unquote(opts[:primary_key]), unquote(opts[:primary_key_type]))
            ),
          on: t.unquote(opts[:primary_key]) == g.unquote(opts[:foreign_key])
        )
      end

      def descendants(struct), do: descendants(struct, 2_147_483_647)

      unquote(descendants)

      def descendants(struct, depth) do
        from(
          t in unquote(definition),
          where:
            t.unquote(opts[:primary_key]) in fragment(
              unquote("""
              WITH RECURSIVE #{opts[:tree_name]} AS (
                SELECT #{opts[:primary_key]},
                       0 AS depth
                FROM #{opts[:table_name]}
                WHERE #{opts[:foreign_key]} = ?
              UNION ALL
                SELECT #{opts[:table_name]}.#{opts[:primary_key]},
                       #{opts[:tree_name]}.depth + 1
                FROM #{opts[:table_name]}
                  JOIN #{opts[:tree_name]}
                  ON #{opts[:table_name]}.#{opts[:foreign_key]} = #{opts[:tree_name]}.#{
                opts[:primary_key]
              }
                WHERE #{opts[:tree_name]}.depth + 1 < ?
              )
              SELECT #{opts[:primary_key]} FROM #{opts[:tree_name]}
              """),
              type(^struct.unquote(opts[:primary_key]), unquote(opts[:foreign_key_type])),
              type(^depth, :integer)
            )
        )
      end
    end
  end
end
