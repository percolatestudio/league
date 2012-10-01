Meteor.startup ->  
  Cron.instance.add_job 1, ->
    now = moment().valueOf()
    
    # 3 days before
    this_week = moment().add('days', 3).valueOf()
    games = Games.find({reminded_weekly: {$exists: false}, date: {$lt: this_week, $gt: now}})
    games.forEach (game) -> 
      game.update_attribute('reminded_weekly', true)
      LeagueMailer.remind_team(game)
    
    # 24 hours before
    tomorrow = moment().add('hours', 24).valueOf()
    games = Games.find({reminded_tomorrow: {$exists: false}, date: {$lt: tomorrow, $gt: now}})
    games.forEach (game) -> 
      game.update_attribute('reminded_tomorrow', true)
      LeagueMailer.remind_team(game)
    
  # ping the server every 30 minutes so it doesn't go to sleep
  Cron.instance.add_job 30, ->
    console.log 'Email heartbeat'
    Meteor.http.call 'GET', LeagueMailerConfig.url + 'reminder'
