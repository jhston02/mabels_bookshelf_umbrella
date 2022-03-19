defmodule MabelsBookshelf.Commands.Book.CommandValidator do
  import Norm

  def validate_create_book_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "external_book_id" => spec(is_binary()),
        "owner_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "external_book_id", "owner_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_finish_book_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "book_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_want_book_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "book_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_quit_book_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "book_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_start_reading_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "book_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_delete_book_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary())
      })

    selection = selection(schema, ["id", "book_id"])

    conform!(
      cmd,
      selection
    )
  end

  def validate_read_to_page_command(cmd) do
    schema =
      schema(%{
        "id" => spec(is_binary()),
        "book_id" => spec(is_binary()),
        "page_number" => spec(is_integer() and (&(&1 > 0)))
      })

    selection = selection(schema, ["id", "book_id", "page_number"])

    conform!(
      cmd,
      selection
    )
  end
end
