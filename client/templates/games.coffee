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

Template.next_game.player_availabilities = Template.game.player_availabilities = -> 
  {game: this, player: p} for p in this.players()

Template.game.month = -> this.moment.format('MMM')

Template.game.date_format = 'MM d, yy'
Template.game.date_for_input = -> this.formatted_date()
Template.game.date_field_id = -> "game-#{this.id}-datepicker"
Template.game.attach_date_picker = ->
  Meteor.defer =>
    game = this
    $("\#game-#{this.id}-datepicker").datepicker
      dateFormat: Template.game.date_format
      minDate: new Date()
      onSelect: (dateText) -> 
        game.set_date($.datepicker.parseDate(Template.game.date_format, dateText))
        
      

Template.game.possible_hours = ->
  game: this
  name: 'hours'
  options: ({text: "#{h}", value: h, selected: h == this.hours()} for h in [1..24])
  
Template.game.possible_minutes = ->
  game: this
  name: 'minutes'
  options: ({text: "#{min}", value: min, selected: min == this.minutes()} for min in [0...60] when min % 5 == 0)

Template.game.expanded = -> Session.equals("game.#{this.id}.expanded", true)
  
Template.game.events =
  'change [name=location]': (e) ->
    this.update_attribute('location', $(e.target).val())
  'change [name=hours]': (e) -> 
    this.game.set_hours($(e.target).val())
  'change [name=minutes]': (e) -> 
    this.game.set_minutes($(e.target).val())
  'change [name=state]': (e) ->
    playing = $(e.target).val() == 'play'
    if playing
      this.playing(current_user())
    else
      this.not_playing(current_user())
  'click .go_unconfirmed': ->
    this.unconfirmed(current_user())
  'click .show_roster': -> 
    Session.set("game.#{this.id}.expanded", true)
  'click .hide_roster': -> 
    Session.set("game.#{this.id}.expanded", false)

Template.game.current_user_availability = -> this.availability(current_user())

Template.player_availability.facebook_profile_url = -> 
  this.facebook_profile_url()

Template.player_availability.availability = -> 
  this.game.availability(this.player)
Template.player_availability.unconfirmed = ->
  this.game.availability(this.player) == 0


Template.player_availability.events =
  'click li.player': -> 
    # FIXME -- meteor forces us to jump through hoops here
    future_games()[0].toggle_availability(this)
