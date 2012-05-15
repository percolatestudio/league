Template.teams.teams = -> Teams.find()

Template.teams.events =
  'click .add_team': ->
    login ->
      console.log 'you are allowed to add a team'