Meteor.startup ->  
  Cron.instance.add_job 1, ->
    now = moment().valueOf()
    # 24 hours before
    tomorrow = moment().add('hours', 24).valueOf()
    games = Games.find({reminded_tomorrow: {$exists: false}, date: {$lt: tomorrow, $gt: now}})
    games.forEach (g) -> 
      game = new Game(g)
      game.update_attribute('reminded_tomorrow', true)
      LeagueMailer.remind_team(game, true)
    
    # 4 hours before
    today = moment().add('hours', 4).valueOf()
    games = Games.find({reminded_today: {$exists: false}, date: {$lt: today, $gt: now}})
    games.forEach (g) -> 
      game = new Game(g)
      game.update_attribute('reminded_today', true)
      LeagueMailer.remind_team(game, false)
    
    