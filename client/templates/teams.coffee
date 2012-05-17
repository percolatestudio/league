Session.set 'adding_player', false

Template.teams.teams = -> Teams.find()

Template.teams.events =
  'click .add_team': -> null

Template.team.players = -> Players.find()
Template.team.adding = -> Session.get 'adding_player'
Template.team.events =
  'click .add_player': -> Session.set 'adding_player', true