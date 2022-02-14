defmodule MabelsBookshelf.Aggregates.EventSourced do
  @moduledoc """
  Default EventSourced module implementation. Note that in order to use this the Aggregate module must contain a struct with an event: atom. The user should also
  override the private apply_event_impl/2 function
  """

  defmacro __using__(opts) do
    module = Keyword.get(opts, :module)
    quote do
      alias MabelsBookshelf.Behaviors.EventSourced
      alias MabelsBookshelf.Behaviors.Event

      @behaviour EventSourced

      @impl EventSourced
      def apply_event(%unquote(module){} = aggregate, %Event{} = event) do
        apply_event_impl(aggregate, event)
        |> bump_version()
      end

      @impl EventSourced
      def add_event(%unquote(module){} = aggregate, %Event{} = event) do
        Map.update(aggregate, :events, [], &([event | &1]))
      end

      @impl EventSourced
      def clear_pending_events(%unquote(module){} = aggregate) do
        %{aggregate | events: []}
      end

      @impl EventSourced
      def get_pending_events(%unquote(module){} = aggregate) do
        aggregate.events
        |> Enum.reverse()
      end

      @impl EventSourced
      def get_version(%unquote(module){} = aggregate) do
        aggregate.version
      end

      defp apply_event_impl(%unquote(module){} = aggregate, %Event{} = _event) do
        aggregate
      end

      defp bump_version(%unquote(module){} = aggregate) do
        Map.update(aggregate, :version, -1, &(&1+1))
      end

      defp when_event(%unquote(module){} = aggregate, %Event{} = event) do
        aggregate
        |> add_event(event)
        |> apply_event(event)
      end

      defoverridable [apply_event_impl: 2]
    end
  end
end
