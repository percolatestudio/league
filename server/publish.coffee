# Published collections
Meteor.publish 'users', (user_id) ->
  console.log "connecting as #{user_id}"
  this.set('users', user_id, Players.findOne(user_id))
  this.flush()

Meteor.publish 'teams', (player_id) -> 
  console.log "getting teams for #{player_id}"
  Teams.find({player_ids: player_id})

# all players for a set of team_ids (the teams of the current player)
Meteor.publish 'players', (team_ids) -> 
  console.log "getting players for #{team_ids}"
  Players.find({team_ids: {$in: team_ids}})

# all games in a set of team_ids (the teams of the current player)
Meteor.publish 'games', (team_ids) -> 
  console.log "getting games for #{team_ids}"
  Games.find({team_id: {$in: team_ids}})
  
# Published methods
Meteor.methods
  'login': (facebook_id) ->
    console.log "logging in user with FB ID: #{facebook_id}"
    Players.findOne facebook_id: facebook_id
  'create': (attributes) ->
    console.log "creating user from #{attributes}"
    # FIXME: need to use a model here to make this safe
    id = Players.insert attributes
    Players.findOne id