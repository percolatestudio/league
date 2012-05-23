Template.games.team = -> current_team()

Template.games.next_game = Template.next_game.next_game = -> future_games()[0]
Template.games.upcoming_games = -> future_games()[1..]
Template.games.events =
  'click .create_game': (event) -> 
    event.preventDefault();
    current_team().add_game()

Template.next_game.players = -> Players.find().forEach (p) -> new Player(p)
