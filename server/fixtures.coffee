Meteor.startup ->
  return unless Teams.find().count() is 0
  
  console.log 'Initializing Fixtures'
  
  player_data = [['Tom Coleman', 'tom@thesnail.org', '680541486'], ['Dominic Nguyen', 'd@dominicnguyen.net', '1230930']]
  players = for player in player_data
    player = Player.create
      name: player[0]
      email: player[1]
      facebook_id: player[2]
      team_ids: []
  
  team = players[0].create_team
    name: "Tom's Fault"
    players_required: 5
  
  # add players to teams
  team.add_player(players[1])
  
  availabilities = {}
  availabilities[players[0].id] = 1
  availabilities[players[1].id] = 2
  team.create_game
    date: moment().add('weeks', 1).day(0).hours(20).minutes(40).valueOf()
    location: 'Brunswick'
    availabilities: availabilities
  
  availabilities = {}
  availabilities[players[0].id] = 1
  team.create_game
    date: moment().add('weeks', 2).day(0).hours(20).minutes(0).valueOf()
    location: 'Princes Hill'
    availabilities: availabilities
  
  