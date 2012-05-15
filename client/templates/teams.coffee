Template.teams.teams = -> Teams.find()

Template.teams.events =
  'click .add_team': ->
    login ->
      console.log 'you are allowed to add a team'

Template.team.events =
  'click .team': ->
    Session.set 'team_id', this._id