Template.games.team = -> current_team()

Template.games.next_game = Template.next_game.next_game = -> future_games()[0]
Template.upcoming_games.upcoming_games = -> 
  future_games()[1..]

Template.upcoming_games.events =
  'click .create_game': (event) -> 
    event.preventDefault();
    new_game = current_team().create_next_game()
    console.log "Game invalid: #{new_game.full_errors()}" unless new_game.valid()
    

Template.next_game.player_availabilities = Template.game.player_availabilities = -> 
  for p in this.players()
    availability = {game: this, player: p}
    # need to circularly link so we can get access to info when events happen FIXME
    availability.player.availability = availability
    availability

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
  'click .editable': (event) ->
    $form = $(event.currentTarget).closest('form')
    field = $(event.currentTarget).attr('data-field')
    toggle_edit_field(field, this)
    
    # redraw, then focus the field
    Meteor.flush()
    $form.find("[name=#{field}]").focus()
  'focusout [name=location]': (e) ->
    field = $(event.currentTarget).attr('name')
    toggle_edit_field(field, this)
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
    console.log this
    console.log this.availability
    this.availability.game.toggle_availability(this)
