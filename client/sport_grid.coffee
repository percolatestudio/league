Session.set 'team_id', null
Session.set 'editing_game_id', null
Session.set 'editing_player_id', null

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

upcoming_games = -> 
  Games.find(
    {date: {$gt: new Date().getTime()}}, {sort: {date: 1}}
  ).fetch()

Template.team_grid.games = upcoming_games

Template.team_grid.players = -> Players.find().fetch()

Template.team_grid.events = 
  'click .add_game': ->
    last_game = Games.findOne({}, {sort: {date: -1}})
    new_game = $.extend({}, last_game)
    
    # make a new date, 1 week in the future
    new_date = new Date(last_game.date)
    new_date.setDate(new_date.getDate() + 7)
    new_game.date = new_date.getTime()
    
    new_game.players = {}
    delete new_game._id
    new_game_id = Games.insert new_game
    Session.set 'editing_game_id', new_game_id
    
  'click .add_player': ->
    new_player_id = Players.insert {team_id: Session.get 'team_id'}
    Session.set 'editing_player_id', new_player_id
    

Template.game_header.format_date = (date) -> new Date(date).toDateString()
Template.game_header.player_count = -> 
  (id for id, state of this.players when state == 1).length
Template.game_header.editing = -> Session.get('editing_game_id') is this._id
Template.game_header.events = 
  'click th': -> Session.set('editing_game_id', this._id)
  'change input': (event) -> 
    # update attribute
    update = {}
    update[$(event.target).attr('name')] = $(event.target).val()
    
    # save to db
    Games.update {_id: this._id}, {$set: update}

Template.player_row.availabilities = ->
  {player: this, game: game} for game in upcoming_games()
Template.player_row.editing = -> Session.get('editing_player_id') is this._id
Template.player_row.empty = -> !(this.name || this.email)
  
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
