games_path = (team) -> "/#{team.id}/season"
players_path = (team) -> "/#{team.id}"

to_url = (path) ->
  if window && window.location
    window.location.origin + path
  else
    LeagueMailer.to_url(path)