# Published collections
Meteor.publish 'teams', (player_id) -> 
  console.log "getting teams for #{player_id}"
  Teams.find({player_ids: player_id})

Meteor.publish 'players', (team_id) -> 
  console.log "getting players for #{team_id}"
  Players.find({team_id: team_id})
Meteor.publish 'games', (team_id) -> 
  console.log "getting games for #{team_id}"
  Games.find({team_id: team_id})

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
    
    # do nothing for now
  # 'logout': -> 
  #   console.log "logging out user with FB ID: #{facebook_id}"
