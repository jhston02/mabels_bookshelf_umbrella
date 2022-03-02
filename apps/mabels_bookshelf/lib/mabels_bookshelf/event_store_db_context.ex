defmodule Mabelsbookshelf.EventStoreDbClient  do
  use Spear.Client, otp_app: :mabels_bookshelf

  def add(module, entity, stream_name) do
    get_events_from_aggregate(module, entity)
    |> events_to_spear_events()
    |> append(stream_name, expect: :empty)
  end

  defp get_events_from_aggregate(module, entity) do
    apply(module, :get_pending_events, [entity])
  end

  defp events_to_spear_events(events) do
    events
    |> Enum.map(&event_to_spear_event/1)
  end

  defp event_to_spear_event(event) do
    Spear.Event.new(event.type, Map.from_struct(event.body))
  end
end
