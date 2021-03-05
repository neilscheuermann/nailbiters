defmodule Nailbiters.Periodically do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the work you desire here
    do_recurring_thing()
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp do_recurring_thing() do
    Nailbiters.NBA.find_live_close_games()
  end

  defp schedule_work() do
    # Every 15 seconds
    Process.send_after(self(), :work, 15 * 1000)
  end
end
