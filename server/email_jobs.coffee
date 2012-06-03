email_tester = ->
  LeagueMailer.signup new Player(Players.findOne())

Meteor.startup ->  
  Cron.instance.add_job 1, email_tester