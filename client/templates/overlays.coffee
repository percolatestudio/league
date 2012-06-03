Template.overlays.show_overlays = -> 'show' if show_overlays()
Template.overlays.events =
  'click .close': -> Session.set('show_overlays', false)
  
  
Template.team_status.team = -> team_status_team()
Template.team_status.events =
  'click .player': ->
    team = team_status_team()
    message = "#{current_user().attributes.name} has invited you to their new league team: #{team.name}"
    link = to_url(games_link(team))
    
    this.send_facebook_message(message, link)
    