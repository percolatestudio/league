Session.set 'adding_player', false

Template.teams.teams = -> Teams.find()
