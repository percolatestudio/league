Meteor.publish 'teams', (player_id) -> 
  console.log "getting teams for #{player_id}"
  Teams.find({player_ids: player_id})

# all players for a set of team_ids (the teams of the current player)
Meteor.publish 'players', (team_ids, player_id) -> 
  console.log "getting players for #{player_id} | #{team_ids}"
  Players.find({$or: [{team_ids: {$in: team_ids}}, {_id: player_id}]})

# all games in a set of team_ids (the teams of the current player)
Meteor.publish 'games', (team_ids) -> 
  console.log "getting games for #{team_ids}"
  Games.find({team_id: {$in: team_ids}})
  
# Published methods
Meteor.methods
  'login': (facebook_id) ->
    console.log "logging in user with FB ID: #{facebook_id}"
    player = Players.findOne facebook_id: facebook_id
    Players.update player._id, {$set: {authorized: true}} unless player.authorized?
    player
    
  'create': (attributes) ->
    console.log "creating user from #{attributes}"
    # FIXME: need to use a model here to make this safe
    id = Players.insert attributes
    Players.findOne id
  
  'team_from_season_ticket': (team_id) ->
    console.log "getting team from season ticket: #{team_id}"
    if team = Teams.findOne(team_id)
      { name: team.name, logo: team.logo }
  
  'start_team': (user_id, team_id) ->
    console.log "Starting team #{team_id}"
    player = new Player(Players.findOne(user_id))
    team = new Team(Teams.findOne(team_id))
    unless team.attributes.started
      LeagueMailer.season_ticket(player, team)
      team.update_attribute('started', true)
    null