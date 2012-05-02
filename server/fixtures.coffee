Meteor.startup ->
  return unless Teams.find().count() is 0
  
  team = Teams.insert
    name: "Tom's Fault"
    password: ''
    day: 1
  
  player_data = [['Tom Coleman', 'tom@thesnail.org'], ['Kris Nilsen', 'kris@thesnail.org']]
  players = for player in player_data
    Players.insert
      name: player[0]
      email: player[1]
      team_id: team.id
  
  game = Games.insert
    date: get_day_after(team.day)
    time: '8:40'
    location: 'Brunswick'
    players: [[players[0].id, 1], [players[1], 2]]
  