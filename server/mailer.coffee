# a simple mailer that just sends JSON to the league mailer, if it's defined
LeagueMailer = (->
  to_url = (path) -> 
    if LeagueMailerConfig?
      LeagueMailerConfig.host + path
    else
      path
      
  games_url = (g) -> to_url games_link(g)
  
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
    send 'season_ticket',
      user: {name: user.attributes.name, email: user.attributes.email}
      team: {name: team.attributes.name, url: games_url(team)}
    
  reminder: (user, team, game) ->
    send 'reminder',
      user: {name: user.attributes.name, email: user.attributes.email}
      team: {name: team.attributes.name, url: games_url(team)}
      game: {date: game.attributes.date, location: game.attributes.location}
  
  problem: (user, team, game) ->
    send 'problem',
      user: {name: user.attributes.name, email: user.attributes.email}
      team: {name: team.attributes.name, url: games_url(team)}
      game: {date: game.attributes.date, location: game.attributes.location, \
        confirmation_count: game.availability_count(1)}
)()
