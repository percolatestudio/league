Session.set 'adding_player', false

Template.teams.teams = -> Teams.find()
Template.team.team_logo = -> (new Logo(this.name)).render()
