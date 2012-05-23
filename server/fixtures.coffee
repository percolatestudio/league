Meteor.startup ->
  return unless Teams.find().count() is 0
  
  console.log 'Initializing Fixtures'
  
  player_data = [['Tom Coleman', 'tom@thesnail.org', '680541486'], ['Dominic Nguyen', 'd@dominicnguyen.net', '1230930']]
  player_ids = for player in player_data
    Players.insert
      name: player[0]
      email: player[1]
      facebook_id: player[2]
      team_ids: []
  
  day = 1
  team_id = Teams.insert
    name: "Tom's Fault"
    players_required: 5
    player_ids: []
  
  # add players to teams
  team = new Team(Teams.findOne(team_id))
  for id in player_ids
    player = new Player(Players.findOne(id))
    unless team.add_player(player)
      console.log "Couldn't add player: #{player.full_errors()} / #{team.full_errors()}"
    
  
  next_date = get_day_after(day)
  players = {}
  players[player_ids[0]] = 1
  players[player_ids[1]] = 2
  game = Games.insert
    team_id: team_id
    date: next_date.getTime()
    time: '8:40'
    location: 'Brunswick'
    players: players
  
  players = {}
  players[player_ids[0]] = 1
  game = Games.insert
    team_id: team_id
    date: get_day_after(day, new Date().setDate(next_date.getDate() + 7)).getTime()
    time: '8:00'
    location: 'Princes Hill'
    players: players
  
  
  