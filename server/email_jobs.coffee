Meteor.startup ->  
  Cron.instance.add_job 1, ->
    now = moment().valueOf()
    # 24 hours before
    tomorrow = moment().add('hours', 24).valueOf()
    games = Games.find({reminded_tomorrow: {$exists: false}, date: {$lt: tomorrow, $gt: now}})
    games.forEach (game) -> 
      game.update_attribute('reminded_tomorrow', true)
      LeagueMailer.remind_team(game, true)
    
    # 4 hours before
    today = moment().add('hours', 4).valueOf()
    games = Games.find({reminded_today: {$exists: false}, date: {$lt: today, $gt: now}})
    games.forEach (game) -> 
      game.update_attribute('reminded_today', true)
      LeagueMailer.remind_team(game, false)
    
  # ping the server every 30 minutes so it doesn't go to sleep
  Cron.instance.add_job 30, ->
    console.log 'Email heartbeat'
    Meteor.http.call 'GET', LeagueMailerConfig.url + 'reminder'
