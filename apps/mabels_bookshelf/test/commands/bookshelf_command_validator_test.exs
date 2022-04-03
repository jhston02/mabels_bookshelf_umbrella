defmodule BookshelfCommandValidatorTest do
  use ExUnit.Case
  alias MabelsBookshelf.Commands.Bookshelf.CommandValidator

  describe "Create bookshelf command" do

    test "Given valid create_bookshelf_command, when validated, passes validation" do
      cmd = %{"id" => "id", "bookshelf_id" => "test", "owner_id" => "owner_id", "name" => "test"}

      assert cmd == CommandValidator.validate_create_bookshelf_command(cmd)
    end

    test "Given invalid create_bookshelf_command, when validated, throws Norm.MismatchError" do
      cmd = %{"bookshelf_id" => 4}

      try do
        CommandValidator.validate_create_bookshelf_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        Norm.SpecError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Delete bookshelf command" do

    test "Given valid delete_bookshelf_command, when validated, passes validation" do
      cmd = %{"id" => "id", "bookshelf_id" => "id"}

      assert cmd == CommandValidator.validate_delete_bookshelf_command(cmd)
    end

    test "Given invalid delete_bookshelf_command, when validated, throws Norm.MismatchError" do
      cmd = %{"bookshelf_id" => 4}

      try do
        CommandValidator.validate_delete_bookshelf_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        Norm.SpecError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Rename bookshelf command" do

    test "Given valid rename_bookshelf_command, when validated, passes validation" do
      cmd = %{"id" => "id", "bookshelf_id" => "id", "name" => "test"}

      assert cmd == CommandValidator.validate_rename_bookshelf_command(cmd)
    end

    test "Given invalid rename_bookshelf_command, when validated, throws Norm.MismatchError" do
      cmd = %{"bookshelf_id" => 4}

      try do
        CommandValidator.validate_rename_bookshelf_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        Norm.SpecError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Add book to bookshelf command" do

    test "Given valid add_book_to_bookshelf, when validated, passes validation" do
      cmd = %{"id" => "id", "bookshelf_id" => "id", "book_id" => "test"}

      assert cmd == CommandValidator.validate_add_book_to_bookshelf_command(cmd)
    end

    test "Given invalid add_book_to_bookshelf, when validated, throws Norm.MismatchError" do
      cmd = %{"bookshelf_id" => 4}

      try do
        CommandValidator.validate_add_book_to_bookshelf_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        Norm.SpecError -> assert true
        _ -> assert false
      end
    end
  end
end
