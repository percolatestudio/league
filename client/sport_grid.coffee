Session.set 'team_id', null

# subscribe to the teams collection, and redirect to one as soon as it exists
Meteor.subscribe 'teams', ->
  return if id = Session.get('team_id') and Teams.findOne({_id: id})
  
  team = Teams.findOne({}, {sort: {name: 1}})
  Router.setTeam(team._id) if team
  
# always subscribe to the players and (TODO: upcoming) games for the given team
Meteor.autosubscribe ->
  return unless team_id = Session.get('team_id')
  
  Meteor.subscribe 'players', team_id
  Meteor.subscribe 'games', team_id

availability = (data) ->
  data.game.players[data.player._id] || 0

Template.team_grid.team = -> 
  return unless team_id = Session.get('team_id')
  Teams.findOne(team_id)

upcoming_games = -> Games.find({date: {$gt: new Date()}}).fetch()

Template.team_grid.games = upcoming_games

Template.team_grid.players = -> Players.find().fetch()

Template.game_header.format_date = (date) -> new Date(date).toDateString()
Template.game_header.player_count = -> 
  (id for id, state of this.players when state == 1).length

Template.player_row.availabilities = ->
  {player: this, game: game} for game in upcoming_games()
  
Template.availability_cell.availability = -> availability(this)
Template.availability_cell.availability_state = (a) -> playing_states[a]
Template.availability_cell.availability_class = (a) -> 
  playing_states[a].toLowerCase().replace(' ', '_')

Template.availability_cell.events =
  'click td': ->
    # need a better way to do this pattern
    update = {}
    update["players.#{this.player._id}"] = (availability(this) + 1) % 3
    Games.update {_id: this.game._id}, {$set: update}
