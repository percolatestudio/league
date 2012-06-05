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


# Overlays are done in a more JQ way because otherwise I'll need to change a
# class on the body, which would require re-drawing the whole page.. which would
# be bad
open_overlays = -> 
  Session.set('show_overlays', true)
  $('body').addClass('overlays_open')

close_overlays = ->
  Session.set('show_overlays', false)
  $('body').removeClass('overlays_open')

show_overlays = -> Session.equals('show_overlays', true)

show_team_status = (team) ->
  open_overlays()
  Session.set('team_status_team_id', team.id)
team_status_team = ->
  data = Teams.findOne(Session.get 'team_status_team_id')
  new Team(data) if data

players_required_data = (selected = 5) ->
  icon: 'player'
  name: 'players_required'
  options: ({text: "#{i} players", value: i, selected: i == parseInt(selected)} for i in [3..18])
