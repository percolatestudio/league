Session.set('editing_games', false)

Template.games.team = -> current_team()

Template.games.next_game = Template.next_game.next_game = -> future_games()[0]
Template.upcoming_games.upcoming_games = -> 
  future_games()[1..]
Template.game.editing = Template.upcoming_games.editing = -> Session.get('editing_games')

Template.upcoming_games.events =
  'click .edit': -> Session.set('editing_games', true)
  'click .done': -> Session.set('editing_games', false)
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

Template.next_game.player_availabilities = -> 
  {game: this, player: p} for p in current_players()

Template.game.possible_hours = -> {options: [1..24]}
Template.game.possible_minutes = -> {options: (min for min in [0...60] when min % 5 == 0)}
Template.game.events =
  'change [name=location]': (e) ->
    this.update_attribute('location', $(e.target).val())
  'change [name=time]': (e) -> 
    this.set_time($(e.target).val())

Template.player_availability.facebook_profile_url = -> 
  this.facebook_profile_url()

Template.player_availability.unconfirmed = ->
  this.game.availability(this.player) == 0

Template.player_availability.availability_class = ->
  this.game.availability_text(this.player).toLowerCase().replace(' ', '_')

Template.player_availability.events =
  'click li.player': -> 
    # FIXME -- meteor forces us to jump through hoops here
    future_games()[0].toggle_availability(this)
