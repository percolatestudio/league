Session.set 'team_id', null

Meteor.startup -> 
  # subscribe to the current user collection and the teams collection
  Meteor.autosubscribe ->
    Meteor.subscribe 'users', Session.get('current_user_id')
    Meteor.subscribe 'teams', Session.get('current_user_id')
  
  # always subscribe to all players and games for teams of the current player
  Meteor.autosubscribe ->
    me = current_user()
    if me
      Meteor.subscribe 'players', me.attributes.team_ids
      Meteor.subscribe 'games', me.attributes.team_ids

Users = new Meteor.Collection('users')

current_user = -> 
  data = Users.findOne()
  new Player(data) if data

current_team = ->
  data = Teams.findOne(Session.get 'team_id')
  new Team(data) if data

current_players = -> current_team().players() if current_team()
future_games = -> current_team().future_games() if current_team()


show_overlays = -> Session.equals('show_overlays', true)

show_team_status = (team) ->
  Session.set('show_overlays', true)
  Session.set('team_status_team_id', team.id)
team_status_team = ->
  data = Teams.findOne(Session.get 'team_status_team_id')
  new Team(data) if data

players_required_data = ->
  name: 'players_required'
  options: ({text: "#{i} players", value: i, selected: i == 5} for i in [3..18])
