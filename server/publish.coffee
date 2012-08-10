Meteor.publish 'teams',  -> 
  console.log "getting teams for #{this.userId()}"
  me = Meteor.users.findOne(this.userId())
  Teams.find({player_ids: me.player_id}) if me

# all players for a set of team_ids (the teams of the current player)
Meteor.publish 'players', (team_ids) -> 
  console.log "getting players for #{this.userId()} | #{team_ids}"
  me = Meteor.users.findOne(this.userId())
  if me
    player_id = Meteor.users.findOne(this.userId()).player_id
    Players.find({$or: [{team_ids: {$in: team_ids}}, {_id: player_id}]})

# all games in a set of team_ids (the teams of the current player)
Meteor.publish 'games', (team_ids) -> 
  console.log "getting games for #{team_ids}"
  Games.find({team_id: {$in: team_ids}})
  
# Published methods
Meteor.methods
  # 'login': (facebook_id) ->
  #   console.log "logging in user with FB ID: #{facebook_id}"
  #   player = Players.findOne facebook_id: facebook_id
  #   if player
  #     player.update_attribute(authorized: true)
  #     player
  #   
  'create_or_update': (attributes) ->
    console.log "creating/updating user from #{attributes}"
        
    attributes.authorized = true
    
    player = Players.findOne(facebook_id: attributes.facebook_id)
    player ||= new Player(attributes)
    
    player.update_attributes
      authorized: true
      email: attributes.email
    
    player
  
  'team_from_season_ticket': (team_id) ->
    console.log "getting team from season ticket: #{team_id}"
    Teams.findOne(team_id)
    
  'start_team': (user_id, team_id) ->
    console.log "Starting team #{team_id}"
    player = Players.findOne(user_id)
    team = Teams.findOne(team_id)
    unless team.attributes.started
      LeagueMailer.season_ticket(player, team)
      team.update_attribute('started', true)
    null
  
  'join_team': (user_id, team_id) ->
    console.log "Joining team #{user_id} -> #{team_id}"
    player = Players.findOne(user_id)
    team = Teams.findOne(team_id)
    if team
      team.add_player(player)
      true
  
  'add_player_to_team_from_email': (team_id, email) ->
    team = Teams.findOne(team_id)
    
    if this.is_simulation
      # on the client just go for it, it'll get overriden soon
      player = Player.create({email: email})
    else
      player = Players.findOne({email: email})
      player ||= Player.create({email: email})
    
    team.add_player(player)
    true
    
  
  'add_player_to_team_from_facebook': (team_id, player_data) ->
    team = Teams.findOne(team_id)
    
    if this.is_simulation
      # on the client just go for it, it'll get overriden soon
      player = Player.create(player_data)
    else
      player = Players.findOne({facebook_id: player_data.facebook_id})
      player ||= Player.create(player_data)
    
    team.add_player(player)
    true
  