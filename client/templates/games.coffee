Template.games.team = -> current_team()

Template.games.next_game = Template.next_game.next_game = -> future_games()[0]
Template.games.upcoming_games = -> future_games()[1..]
Template.games.events =
  'click .create_game': (event) -> 
    event.preventDefault();
    now = moment()
    if last_game = _.last(future_games())
      new_game = last_game.clone_one_week_later()
      
    else if last_game = Games.findOne({}, {sort: {date: -1}})
      # as the last game is in the past, this could also be in the past...
      new_game = last_game.clone_one_week_later()
      new_game.add('weeks', 1) while now.diff(new_game) < 0
    
    else
      date = moment().add('days', 1).hours(20).minutes(0)
      new_game = new Game({team_id: current_team().id, date: date.valueOf()})
      
    console.log "Game invalid: #{new_game.full_errors()}" unless new_game.save()

Template.next_game.players = -> Players.find().forEach (p) -> new Player(p)
