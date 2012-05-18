Session.set 'team_id', null
Session.set 'current_user', null
Session.set 'editing_game_id', null
Session.set 'editing_player_id', null

# subscribe to the teams collection
Meteor.autosubscribe -> 
  current_user = Session.get 'current_user'
  Meteor.subscribe 'teams', current_user._id if current_user

# always subscribe to the players and (TODO: upcoming) games for the given team
Meteor.autosubscribe ->
  team_id = Session.get('team_id')
  Meteor.subscribe 'players', team_id
  Meteor.subscribe 'games', team_id

availability = (data) ->
  data.game.players[data.player._id] || 0

future_games = -> 
  Games.find(
    {date: {$gt: new Date().getTime()}}, {sort: {date: 1}}
  ).fetch()

current_team = -> new Team(Teams.findOne(Session.get 'team_id'))



######### SESSION ACTIONS
toggle_session = (key, value) -> 
  if Session.equals(key, value)
    Session.set(key, null)
  else
    Session.set(key, value)

toggle_player_state = (player) ->
  toggle_session('editing_player_id', player._id)
toggle_game_state = (game) ->
  toggle_session('editing_game_id', game._id)

# ##### GENERIC EVENTS
# make_edit_function = (collection_name, attributes, callback) -> 
#   (e) ->
#     collection = window[collection_name]
#     $link = $(e.target)
#     save = $link.hasClass('save')
#     destroy = $link.hasClass('delete')
#     
#     if save
#       update = {}
#       for key in attributes
#         update[key] = $link.closest('th').find("input[name^=#{key}]").val()
#       collection.update {_id: this._id}, {$set: update}
#     else if destroy
#       collection.remove {_id: this._id}
#     
#     callback.call(this)
# 
# 
# 
# ############# HELPERS ###########
# Template.team_grid.current_user = -> Session.get('current_user')
# 
# Template.team_grid.games = upcoming_games
# 
# Template.team_grid.players = -> Players.find().fetch()
# 
# Template.team_grid.events = 
#   'click .add_game': ->
#     last_game = Games.findOne({}, {sort: {date: -1}})
#     new_game = $.extend({}, last_game)
#     
#     # make a new date, 1 week in the future
#     new_date = new Date(last_game.date)
#     new_date.setDate(new_date.getDate() + 7)
#     new_game.date = new_date.getTime()
#     
#     new_game.players = {}
#     delete new_game._id
#     new_game_id = Games.insert new_game
#     Session.set 'editing_game_id', new_game_id
#     
#   'click .add_player': ->
#     new_player_id = Players.insert {team_id: Session.get 'team_id'}
#     Session.set 'editing_player_id', new_player_id
#     
# 
# Template.game_header.format_date = (date) -> new Date(date).toDateString()
# Template.game_header.player_count = -> 
#   (id for id, state of this.players when state == 1).length
# Template.game_header.editing = -> Session.get('editing_game_id') is this._id
# Template.game_header.events = 
#   'click .edit-btns': 
#     make_edit_function('Games', ['date', 'time', 'location'], -> toggle_game_state(this))
# 
# Template.player_row.availabilities = ->
#   {player: this, game: game} for game in upcoming_games()
# Template.player_row.editing = -> Session.get('editing_player_id') is this._id
# Template.player_row.empty = -> !(this.name || this.email)
# Template.player_row.events =
#   'click .edit-btns': 
#     make_edit_function('Players', ['name', 'email'], -> toggle_player_state(this))
#   'click .empty-player': -> toggle_player_state(this)
#   
# Template.availability_cell.availability = -> availability(this)
# Template.availability_cell.availability_state = (a) -> playing_states[a]
# Template.availability_cell.availability_class = (a) -> 
#   playing_states[a].toLowerCase().replace(' ', '_')
# 
# Template.availability_cell.events =
#   'click td': ->
#     # need a better way to do this pattern
#     update = {}
#     update["players.#{this.player._id}"] = (availability(this) + 1) % 3
#     Games.update {_id: this.game._id}, {$set: update}
