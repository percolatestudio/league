games_link = (team) -> "/#{team.id}/season"
players_link = (team) -> "/#{team.id}"

to_url = (path) ->
  if window && window.location
    window.location.origin + path
  else
    LeagueMailer.to_url(path)