defmodule MabelsBookshelf.Commands.Bookshelf.CommandValidator do
  import Norm

  def validate_create_bookshelf_command(cmd) do
    schema = schema(%{
      "id" => spec(is_binary()),
      "bookshelf_id" => spec(is_binary()),
      "name" => spec(is_binary()),
      "owner_id" => spec(is_binary())
    })

    selection = selection(schema, ["id", "name", "owner_id", "bookshelf_id"])

    conform!(cmd, selection)
  end

  def validate_delete_bookshelf_command(cmd) do
    schema = schema(%{
      "id" => spec(is_binary()),
      "bookshelf_id" => spec(is_binary())
    })

    selection = selection(schema, ["id", "bookshelf_id"])

    conform!(cmd, selection)
  end

  def validate_rename_bookshelf_command(cmd) do
    schema = schema(%{
      "id" => spec(is_binary()),
      "bookshelf_id" => spec(is_binary()),
      "name" => spec(is_binary())
    })

    selection = selection(schema, ["id", "bookshelf_id", "name"])

    conform!(cmd, selection)
  end

  def validate_add_book_to_bookshelf_command(cmd) do
    schema = schema(%{
      "id" => spec(is_binary()),
      "bookshelf_id" => spec(is_binary()),
      "book_id" => spec(is_binary())
    })

    selection = selection(schema, ["id", "bookshelf_id", "book_id"])

    conform!(cmd, selection)
  end
end
