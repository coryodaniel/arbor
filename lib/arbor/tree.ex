defmodule Arbor.Tree do
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
    {prefix, source} = struct_fields[:__meta__].source

    array_type = case primary_key_type do
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
      source: {prefix, source},
      array_type: array_type,
      orphan_strategy: :nothing
    ]

    opts = Keyword.merge(default_opts, arbor_opts)

    quote do
      import Ecto.Query

      def parent(struct) do
        from t in unquote(definition),
          where: fragment(unquote("#{opts[:primary_key]} = ?"), type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type])))
      end

      def roots do
        from t in unquote(definition),
          where: fragment(unquote("#{opts[:foreign_key]} IS NULL"))
      end

      def siblings(struct) do
        from t in unquote(definition),
          where: t.unquote(opts[:primary_key]) != type(^struct.unquote(opts[:primary_key]), unquote(opts[:primary_key_type])),
          where: fragment(unquote("#{opts[:foreign_key]} = ?"),
                          type(^struct.unquote(opts[:foreign_key]), unquote(opts[:foreign_key_type])))
      end

      def children(struct) do
        from t in unquote(definition),
          where: fragment(unquote("#{opts[:foreign_key]} = ?"), type(^struct.id, unquote(opts[:foreign_key_type])))
      end

      def descendants(struct) do
        from t in unquote(definition),
          join: g in fragment(unquote("""
          WITH RECURSIVE #{opts[:tree_name]} AS (
            SELECT #{opts[:primary_key]}, ARRAY[]::#{opts[:array_type]}[] AS ancestors
            FROM #{opts[:table_name]}
            WHERE #{opts[:foreign_key]} = ?
          UNION ALL
            SELECT #{opts[:table_name]}.#{opts[:primary_key]}, #{opts[:tree_name]}.ancestors || #{opts[:table_name]}.#{opts[:foreign_key]}
            FROM #{opts[:table_name]}, #{opts[:tree_name]}
            WHERE #{opts[:table_name]}.#{opts[:foreign_key]} = #{opts[:tree_name]}.#{opts[:primary_key]}
          )
          SELECT * FROM #{opts[:tree_name]}
          """), type(^struct.id, unquote(opts[:foreign_key_type]))),
          on: t.id == g.id
      end
    end
  end
end
