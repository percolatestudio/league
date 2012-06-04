Session.set 'adding_player', false

Template.teams.teams = -> Teams.find().map((t) -> new Team(t))

Template.team.games_path = -> games_path(this)
Template.team.players_path = -> players_path(this)
Template.team.events = 
  'click .new_logo': ->
    this.prepare_logo(true)
    this.save()
  'click .remove_team': ->
    this.destroy()
  'click .team_status': ->
    show_team_status(this)

Template.team_builder.players_required_data = -> players_required_data()
