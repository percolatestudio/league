Session.set 'adding_player', false

Template.teams.teams = -> Teams.find().map((t) -> new Team(t))
Template.team.team_logo = -> (new Logo(this)).render()
Template.team.games_link = games_link
Template.team.players_link = players_link
