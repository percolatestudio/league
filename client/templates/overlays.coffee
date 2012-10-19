Template.overlays.preserve(['#overlays', '.overlay']);
Template.overlays.show_overlays = -> 'show' if show_overlays()
Template.overlays.events =
  'click .close': -> close_overlays()
  
  
Template.team_status.team = -> team_status_team()
Template.team_status.unauthorized_players = -> this.players({authorized: undefined})
Template.team_status.events =
  'click .invite': ->
    team = team_status_team()
    message = "#{current_user().attributes.name} has invited you to their new league team: #{team.attributes.name}"
    link = to_url(games_path(team))
    
    this.send_facebook_message(message, link)
    