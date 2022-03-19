defmodule BookCommandValidatorTest do
  use ExUnit.Case

  alias MabelsBookshelf.Commands.Book.CommandValidator

  describe "Create book command" do
    test "Given valid create_book_command, when validated, passes validation" do
      cmd = %{"id" => "id", "external_book_id" => "test", "owner_id" => "owner_id"}

      assert cmd == CommandValidator.validate_create_book_command(cmd)
    end

    test "Given invalid create_book_command, when validated, throws Norm.MismatchError" do
      cmd = %{"external_book" => 4}

      try do
        CommandValidator.validate_create_book_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        Norm.SpecError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Finish book command" do
    test "Given valid finish_book_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_finish_book_command(cmd)
    end

    test "Given invalid finish_book_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_finish_book_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Want book command" do
    test "Given valid want_book_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_want_book_command(cmd)
    end

    test "Given invalid want_book_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_want_book_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Quit book command" do
    test "Given valid quit_book_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_quit_book_command(cmd)
    end

    test "Given invalid quit_book_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_quit_book_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Start reading book command" do
    test "Given valid start_reading_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_start_reading_command(cmd)
    end

    test "Given invalid start_reading_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_start_reading_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Delete book command" do
    test "Given valid delete_book_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_delete_book_command(cmd)
    end

    test "Given invalid delete_book_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_delete_book_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end

  describe "Read to page command" do
    test "Given valid read_to_page_command, when validated, passes validation" do
      cmd = %{"id" => "test"}

      assert cmd == CommandValidator.validate_read_to_page_command(cmd)
    end

    test "Given invalid read_to_page_command, when validated, throws Norm.MismatchError" do
      cmd = %{"id" => 4}

      try do
        CommandValidator.validate_read_to_page_command(cmd)
      rescue
        Norm.MismatchError -> assert true
        _ -> assert false
      end
    end
  end
end
