# a simple mailer that just sends JSON to the league mailer, if it's defined
LeagueMailer = (->
  to_url = (path) -> 
    if LeagueMailerConfig?
      LeagueMailerConfig.host + path
    else
      path
      
  games_url = (g) -> to_url games_path(g)
  
  send = if LeagueMailerConfig?
    (mail, data) ->
      console.log "Sending mail #{mail}, to #{LeagueMailerConfig.url}"
      options = 
        params: {mail: mail, data: JSON.stringify(data)}
        auth: LeagueMailerConfig.auth
      Meteor.http.call 'POST', LeagueMailerConfig.url, options, ->
        console.log(arguments)
  else
    (mail) -> 
      console.log "Not sending mail #{mail}, no mailer defined"
  
  signup: (user) ->
    send 'signup',
      user: {name: user.attributes.name, email: user.attributes.email} 
      
  season_ticket: (user, team) ->
    players = for player in team.players()
      {name: player.attributes.name, facebook_id: player.attributes.facebook_id} 
    send 'season_ticket',
      base: LeagueMailerConfig.host
      user: {name: user.attributes.name, email: user.attributes.email}
      team: 
        name: team.attributes.name, url: games_url(team) + '#season-ticket'
        players: players
  
  remind_team: (game, tomorrow) ->
    team = game.team()

    base_url = games_url(team)
    data = 
      base: LeagueMailerConfig.host
      team: {name: team.attributes.name, url: base_url}
      game: 
        date: game.attributes.date
        zone: game.attributes.zone
        location: game.attributes.location
        tomorrow: tomorrow
        team_state: game.team_state_key()
        confirmation_count: game.availability_count(1)
        player_deficit: game.player_deficit()
        playing_url: base_url + "\#playing-#{game.id}"
        not_playing_url: base_url + "\#not_playing-#{game.id}"
        confirmation_url: base_url + "\#confirmation-#{game.id}"
    
    for player in game.players({authorized: true})
      data.user = {name: player.attributes.name, email: player.attributes.email}
      data.game.player_state = game.availability_text(player).toLowerCase().replace(' ', '_')
      
      send 'reminder', data
)()
