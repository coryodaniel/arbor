defmodule Arbor.AncestorsTest do
  use Arbor.TestCase


  describe "ancestors/1 with an integer PK" do
    test "given a struct w/ returns its ancestors" do
      [root, branch1, _, leaf2, _, _] = create_chatter("pupperinos")

      # import Ecto.Query
      # query = from c in Comment,
      #         join: ct in "v_comments_tree",
      #         on: c.id == ct.id,
      #         where: fragment("? = ANY(ancestors)", ^leaf2.id)

      query = leaf2
              |> Comment.ancestors
              |> Comment.by_inserted_at

      # {q, arg_list} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
      # IO.puts q
      # IO.inspect arg_list
      ancestors = query |> Repo.all

      assert ancestors == [root, branch1]
    end
  end

  describe "ancestors/1 with a UUID PK" do
    test "given a struct w/ returns its ancestors" do
      root = create_folder("chauncy")
      docs = create_folder("Documents", parent: root)
      downloads = create_folder("Downloads", parent: root)

      resumes = create_folder("resumes", parent: docs)
      create_folder("taxes", parent: docs)
      create_folder("movies", parent: downloads)

      ancestors = resumes
                  |> Folder.ancestors
                  |> Folder.by_inserted_at
                  |> Repo.all

      assert ancestors == [root, docs]
    end
  end
end
