Meteor.publish 'teams', -> Teams.find()

Meteor.publish 'players', (team_id) -> 
  console.log "getting players for #{team_id}"
  Players.find({team_id: team_id})
Meteor.publish 'games', (team_id) -> Games.find({team_id: team_id})