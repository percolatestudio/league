Session.set 'adding_player', false

Template.teams.teams = -> Teams.find()

Template.teams.events =
  'submit .team_builder': (event) -> 
    event.preventDefault()
    
    $form = $(event.target)
    t = {}
    t[pair.name] = pair.value for pair in $form.serializeArray()
    t.player_ids = [Session.get('current_user')._id]
    
    team = Team.create(t)
    # FIXME -- display errors..
    console.log team.errors unless team.valid()