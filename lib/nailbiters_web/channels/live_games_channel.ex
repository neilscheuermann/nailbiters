defmodule NailbitersWeb.LiveGamesChannel do
  use NailbitersWeb, :channel

  def join("live_games:lobby", payload, socket) do
    {:ok, "Welcome to the Live Games Lobby", socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (live_games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("new_game_data", payload, socket) do
    push(socket, "new_game_data", payload)
    {:noreply, socket}
  end
end
