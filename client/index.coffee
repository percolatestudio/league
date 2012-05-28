Session.set 'team_id', null
Session.set 'editing_game_id', null
Session.set 'editing_player_id', null

Meteor.startup -> 
  # subscribe to the current user collection and the teams collection
  Meteor.autosubscribe ->
    Meteor.subscribe 'users', Session.get('current_user_id')
    Meteor.subscribe 'teams', Session.get('current_user_id')
  
  # always subscribe to all players and games for teams of the current player
  Meteor.autosubscribe ->
    me = current_user()
    Meteor.subscribe 'players', me.attributes.team_ids
    Meteor.subscribe 'games', me.attributes.team_ids

Users = new Meteor.Collection('users')
current_user = -> new Player(Users.findOne())


# not sure if this is a good idea. Rethink
current_team = ->
  data = Teams.findOne(Session.get 'team_id')
  new Team(data) if data

current_players = -> current_team().players()




future_games = -> 
  match = {team_id: Session.get('team_id'), date: {$gt: new Date().getTime()}}
  Games.find(match, {sort: {date: 1}}).map (g) -> new Game(g)

