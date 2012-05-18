Session.set 'adding_player', false

Template.teams.teams = -> Teams.find()

Template.teams.events =
  'submit .team_builder': (event) -> 
    event.preventDefault()
    
    # validate
    $form = $(event.target)
    team = {}
    team[pair.name] = pair.value for pair in $form.serializeArray()
    
    team_create(team)