Session.set 'team_id', null
Session.set 'editing_game_id', null
Session.set 'editing_player_id', null

# subscribe to the current user collection and the teams collection
Meteor.autosubscribe ->
  Meteor.subscribe 'users', Session.get('current_user_id')
  Meteor.subscribe 'teams', Session.get('current_user_id')

Users = new Meteor.Collection('users')

# always subscribe to the players and (TODO: upcoming) games for the given team
Meteor.autosubscribe ->
  team_id = Session.get('team_id')
  Meteor.subscribe 'players', team_id
  Meteor.subscribe 'games', team_id

availability = (data) ->
  data.game.players[data.player._id] || 0

future_games = -> 
  match = {team_id: Session.get('team_id'), date: {$gt: new Date().getTime()}}
  Games.find(match, {sort: {date: 1}}).map (g) -> new Game(g)

# not sure if this is a good idea. Rethink
_teams = {}
current_team = ->
  team_id = Session.get 'team_id'
  data = Teams.findOne(team_id)
  _teams[team_id] ||= new Team(data) if data

current_players = -> Players.find().map((p) -> new Player(p))

current_user = -> new Player(Users.findOne())