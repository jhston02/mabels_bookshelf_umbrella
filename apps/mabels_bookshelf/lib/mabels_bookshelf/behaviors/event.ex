defmodule MabelsBookshelf.Behaviors.Event do
  defstruct [:type, :id, :time, data: %{}]
end
