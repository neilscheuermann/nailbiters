defmodule Nailbiters.Periodically do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed on start
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    Nailbiters.NBA.find_live_close_games()
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # Every 15 seconds
    Process.send_after(self(), :work, 15 * 1000)
  end
end
