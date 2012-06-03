Session.set 'adding_player', false

Template.teams.teams = -> Teams.find().map((t) -> new Team(t))

Template.team.games_link = -> games_link(this)
Template.team.players_link = -> players_link(this)
Template.team.events = 
  'click .new_logo': ->
    this.prepare_logo(true)
    this.save()
  'click .remove_team': ->
    this.destroy()
  'click .team_status': ->
    show_team_status(this)

Template.team_builder.players_required_data = -> players_required_data()
