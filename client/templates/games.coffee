Template.games.team = ->
  return unless team_id = Session.get('team_id')
  Teams.findOne(team_id)
Template.games.games = -> upcoming_games()