Meteor.startup ->
  return unless Teams.find().count() is 0
  
  console.log 'Initializing Fixtures'
  
  team = Teams.insert
    name: "Tom's Fault"
    password: ''
    day: 1
  
  player_data = [['Tom Coleman', 'tom@thesnail.org'], ['Kris Nilsen', 'kris@thesnail.org']]
  players = for player in player_data
    Players.insert
      name: player[0]
      email: player[1]
      team_id: team
  
  next_date = get_day_after(team.day)
  
  Games.insert
    team_id: team
    date: next_date
    time: '8:40'
    location: 'Brunswick'
    players: [[players[0], 1], [players[1], 2]]
  
  Games.insert
    team_id: team
    date: get_day_after(team.day, new Date().setDate(next_date.getDate() + 7))
    time: '8:00'
    location: 'Princes Hill'
    players: [[players[0], 1]]
  