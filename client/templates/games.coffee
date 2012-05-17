Template.games.team = -> Teams.findOne(Session.get('team_id'))
  


Template.games.games = -> upcoming_games()


Template.next_game.next_game = -> upcoming_games()[0]

Template.next_game.day = -> days_of_week[new Date(this.date).getDay()]
Template.next_game.formatted_date = -> new Date(this.date).toLocaleDateString()

