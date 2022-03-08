defmodule MabelsBookshelf.Commands.Book.CommandValidator do
  import Norm

  @create_book_command_schema schema(%{
    "ownerId" => spec(is_binary()),
    "externalBookId" => spec(is_binary())
  })

end
