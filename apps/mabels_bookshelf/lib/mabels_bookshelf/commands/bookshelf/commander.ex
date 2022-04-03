defmodule MabelsBookshelf.Commands.Bookshelf.Commander do

  alias MabelsBookshelf.Commands.Bookshelf.CommandValidator
  alias MabelsBookshelf.Repo
  alias MabelsBookshelf.Aggregates.Bookshelf

  def create_bookshelf(cmd) do
    cmd
    |> CommandValidator.validate_create_bookshelf_command()
    |> create_bookshelf_from_command()
    |> Repo.insert(Bookshelf, to_stream_id(cmd["bookshelf_id"]))
  end

  defp create_bookshelf_from_command(cmd) do
    Bookshelf.new(cmd["bookshelf_id"], cmd["owner_id"], cmd["name"])
  end

  def delete_bookshelf(cmd) do

  end

  defp to_stream_id(bookshelf_id) do
    "bookshelf-" <> bookshelf_id
  end
end
