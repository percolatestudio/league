Session.set 'team_id', null

Meteor.startup -> 
  # this will resubscribe when:
  #  a) current_user_id changes
  #  b) me changes
  Meteor.autosubscribe ->
    me = current_player()
    team_ids = (me.attributes.team_ids if me) || []
    
    Meteor.subscribe 'teams'
    Meteor.subscribe 'players', team_ids
    Meteor.subscribe 'games', team_ids
    

current_player = -> 
  me = Meteor.user()
  Players.findOne(me.player_id) if me

Handlebars.registerHelper 'currentPlayer', current_player

current_team = ->
  Teams.findOne(Session.get 'team_id')
  
current_players = -> current_team().players() if current_team()
future_games = -> current_team().future_games().fetch() if current_team()


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
  Teams.findOne(Session.get 'team_status_team_id')