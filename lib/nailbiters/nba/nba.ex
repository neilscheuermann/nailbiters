defmodule Nailbiters.NBA do
  # TODO>>> Add docs?

  def find_live_close_games() do
    todays_date = get_formatted_date(DateTime.utc_now())

    # TODO: Use Timex to get currnet date in PDT timezone
    todays_date = "20210221"

    # 1. Get all today's games.
    {:ok, todays_games} = fetch_daily_games(todays_date)

    # 2. Find live games
    live_games =
      todays_games
      |> Enum.filter(&is_live_game/1)

    # 3. Get data for each game and send to client
    live_nailbiters =
      live_games
      |> Enum.map(fn game -> extract_game_data(todays_date, game) end)
      |> IO.inspect(label: "live_nailbiters>>>")

    # 4. Push live_nailbiter data through Subs to client
  end

  defp extract_game_data(date, game) do
    # 1. Fetch play-by-play data and get most recent play
    {:ok, data} = fetch_game_play_by_play(date, game["gameId"])

    most_recent_play =
      data
      |> Map.get("sports_content")
      |> Map.get("game")
      |> Map.get("play")
      |> List.last()

    # 2. Extract data into %LiveNailbiter{} struct
    {home_score, _} = Integer.parse(Map.get(most_recent_play, "home_score"))
    {visitor_score, _} = Integer.parse(Map.get(most_recent_play, "visitor_score"))

    home_tricode =
      game
      |> Map.get("hTeam")
      |> Map.get("triCode")

    visitor_tricode =
      game
      |> Map.get("vTeam")
      |> Map.get("triCode")

    nailbiter = %{
      point_diff: abs(home_score - visitor_score),
      period: Map.get(most_recent_play, "period"),
      clock: Map.get(most_recent_play, "clock"),
      h_team: %{
        score: home_score,
        tricode: home_tricode
      },
      v_team: %{
        score: visitor_score,
        tricode: visitor_tricode
      }
    }
  end

  defp is_live_game(%{"isGameActivated" => true}), do: true

  defp is_live_game(_), do: false

  defp extract_games(body) do
    body |> Jason.decode!() |> Map.get("games")
  end

  defp extract_game_id(body) do
    body |> Map.get("gameId")
  end

  defp fetch_daily_games(date) do
    case HTTPoison.get("http://data.nba.net/prod/v1/#{date}/scoreboard.json") do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, extract_games(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # Returns a formatted YYYYMMDD string
  defp get_formatted_date(date) do
    date
    |> DateTime.to_iso8601(:basic)
    |> String.slice(0..7)
  end

  defp fetch_game_play_by_play(date, game_id) do
    case HTTPoison.get(
           "http://data.nba.net/data/10s/json/cms/noseason/game/#{date}/#{game_id}/pbp_all.json"
         ) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp fetch_nba_endpoints() do
    case HTTPoison.get("http://data.nba.net/prod/v1/today.json") do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
