Template.games.team = -> current_team()

Template.games.upcoming_games = -> future_games()[1..]

Template.next_game.next_game = -> future_games()[0]

Template.next_game.day = -> days_of_week[new Date(this.date).getDay()]
Template.next_game.formatted_date = -> new Date(this.date).toLocaleDateString()

Template.next_game.players = -> Players.find()