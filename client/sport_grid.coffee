Session.set 'team_id', null

# subscribe to the teams collection, and redirect to one as soon as it exists
Meteor.subscribe 'teams', ->
  return if Session.get('team_id')
  
  team = Teams.findOne({}, {sort: {name: 1}})
  Router.setTeam(team._id) if team
  
# always subscribe to the players and (TODO: upcoming) games for the given team
Meteor.autosubscribe ->
  return unless team_id = Session.get('team_id')
  
  Meteor.subscribe 'players', team_id
  Meteor.subscribe 'games', team_id

availability = (game, player) -> 
  code = (p[1] for p in game.players when p[0] is player._id)[0] || 0
  playing_states[code]


Template.team_grid.team = -> 
  return unless team_id = Session.get('team_id')
  Teams.findOne(team_id)

all_games = -> Games.find().fetch()

Template.team_grid.games = all_games
Template.team_grid.players = -> Players.find().fetch()
  
Template.player_row.availabilities = ->
  availability(game, this) for game in all_games()
  