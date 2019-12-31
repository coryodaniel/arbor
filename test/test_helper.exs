defmodule Arbor.TestCase do
  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
      alias Arbor.{Repo, Comment, Folder, Foreign}

      def create_folder(name), do: create_folder(name, parent: nil)

      def create_folder(name, parent: parent) do
        folder =
          case parent do
            nil -> %Folder{name: name}
            parent -> %Folder{name: name, parent_id: parent.id}
          end

        folder |> Repo.insert!()
      end

      def create_chatter(subject), do: create_conversation(subject)

      def create_conversation(subject) do
        root = %Comment{body: "Lets talk about #{subject}"} |> Repo.insert!()

        branch1 =
          %Comment{body: "Oh gawd, I luv #{subject}", parent_id: root.id} |> Repo.insert!()

        leaf1 = %Comment{body: "Me too!", parent_id: branch1.id} |> Repo.insert!()
        leaf2 = %Comment{body: "They're the best", parent_id: branch1.id} |> Repo.insert!()

        branch2 =
          %Comment{body: "#{subject} are not my thing.", parent_id: root.id} |> Repo.insert!()

        leaf3 = %Comment{body: "Agreed. No me gusta.", parent_id: branch2.id} |> Repo.insert!()

        [
          root,
          branch1,
          leaf1,
          leaf2,
          branch2,
          leaf3
        ]
      end

      def create_foreign(name), do: create_foreign(name, parent: nil)

      def create_foreign(name, parent: parent) do
        foreign =
          case parent do
            nil -> %Foreign{name: name}
            parent -> %Foreign{name: name, parent_uuid: parent.uuid}
          end

        foreign |> Repo.insert!()
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Arbor.Repo, :manual)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Arbor.Repo)
  end
end

Arbor.Repo.start_link()
ExUnit.start()
