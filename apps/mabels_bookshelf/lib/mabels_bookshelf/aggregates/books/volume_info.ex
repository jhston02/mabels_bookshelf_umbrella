defmodule MabelsBookshelf.Aggregates.Book.VolumeInfo do
  @moduledoc """
  Generic book information that applies to all books for an isbn
  """

  defstruct [title: nil, authors: [], isbn: nil, external_id: nil, total_pages: 0, categories: []]

  @doc """
  Create new volume info
  """
  def new(title, authors, isbn, external_id, total_pages, categories) do
    %__MODULE__{
      title: title,
      authors: authors,
      isbn: isbn,
      external_id: external_id,
      total_pages: total_pages,
      categories: categories
    }
  end
end
