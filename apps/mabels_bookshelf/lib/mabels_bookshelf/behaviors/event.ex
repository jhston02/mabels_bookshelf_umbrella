defmodule MabelsBookshelf.Behaviors.Event do
  defstruct type: nil, body: %{}, metadata: %{}

  @doc """
  Creates a new event
  """
  def new(type, body) do
    %__MODULE__{
      type: type,
      body: body
    }
  end
end
