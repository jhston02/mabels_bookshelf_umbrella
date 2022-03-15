defmodule MabelsBookshelf.Commands.Book.CommandValidator do
  import Norm

  @create_book_command_schema schema(%{
    "external_book_id" => spec(is_binary())
  })

  @finish_book_command_schema schema(%{
    "id" => spec(is_binary())
  })

  @mark_book_as_dnf_command_schema schema(%{
    "id" => spec(is_binary())
  })

  @mark_book_as_wanted_command_schema schema(%{
    "id" => spec(is_binary())
  })

  @start_reading_command_schema schema(%{
    "id" => spec(is_binary())
  })

  @read_to_page_command_schema schema(%{
    "id" => spec(is_binary()),
    "page_number" => spec(is_integer() and &(&1 > 0))
  })

  @delete_book_command_schema schema(%{
    "id" => spec(is_binary())
  })

  def validate_create_book_command(cmd) do
    conform!(cmd, @create_book_command_schema)
  end

  def validate_finish_book_command(cmd) do
    conform!(cmd, @finish_book_command_schema)
  end

  def validate_want_book_command(cmd) do
    conform!(cmd, @mark_book_as_wanted_command_schema)
  end

  def validate_quit_book_command(cmd) do
    conform!(cmd, @mark_book_as_dnf_command_schema)
  end

  def validate_start_reading_command(cmd) do
    conform!(cmd, @start_reading_command_schema)
  end

  def validate_delete_book_command(cmd) do
    conform!(cmd, @delete_book_command_schema)
  end

  def validate_read_to_page_command(cmd) do
    conform!(cmd, @read_to_page_command_schema)
  end
end
