
Games = new Meteor.Collection 'games'
# { team_id: 123,
#   date: 1318781876406, location: 'Brunswick',
#   availabilities: {player_id: state} }

class Game extends Model
  @playing_states = ['Unconfirmed', 'Playing', 'Not Playing']
  @team_states = ['Ready', 'Unconfirmed', 'Need players']
  @_collection: Games
  constructor: (attrs) -> 
    super(attrs)
    @attributes.availabilities ||= {}
    # sensible default date
    @attributes.date ||= moment().minutes(0).add('hours', 3).valueOf()
    @moment = moment(@attributes.date)
  
  valid: ->
    @errors = {}
    
    unless @attributes.team_id
      @errors.team_id = 'must be set'
    
    unless @attributes.date? and parseInt(@attributes.date) > 0
      @errors.date = 'must be a valid timestamp'
    
    _.isEmpty(@errors)
  
  # set the date from a moment
  set_date: (m) ->
    @moment = m
    @attributes.date = @moment.valueOf()
  
  qualified_day: -> 
    days_away = @moment.diff(moment(), 'days')
    if days_away == 0
      'Today'
    else if days_away == 1
      'Tomorrow'
    else 
      day = moment.weekdays[@moment.day()]
      if days_away <= 7
        "This #{day}"
      else if days_away <= 14
        "Next #{day}"
      else
        day
  
  time: -> @moment.format('h:mm a')
  
  date: -> @moment.date()
  hours: -> @moment.hours()
  minutes: -> @moment.minutes()
  
  formatted_date: -> @moment.format('MMMM Do, YYYY')
  
  save_moment: -> @update_attribute('date', @moment.valueOf())
  
  # set the date portion
  set_date: (date) -> 
    date = moment(date)
    @moment.year(date.year())
    @moment.month(date.month())
    @moment.date(date.date())
    @save_moment()
  
  set_hours: (h) ->
    @moment.hours(h)
    @save_moment()
  
  set_minutes: (h) ->
    @moment.minutes(h)
    @save_moment()
  
  clone_one_week_later: ->
    new Game(
      team_id: @attributes.team_id
      date: moment(@moment).add('weeks', 1).valueOf()
    )
  
  availability: (player) ->
    @attributes.availabilities[player.id] || 0
  
  availability_text: (player) ->
    Game.playing_states[@availability(player)]
  
  # the order that we should put players in: playing, unconfirmed, not_playing
  availability_order: (player) ->
    [1, 0, 2][this.availability(player)]
  
  @toggle_availability: (availability) ->
    (availability + 1) % Game.playing_states.length
    
  # jump through each of the states
  toggle_availability: (player) ->
    @attributes.availabilities[player.id] = 
      Game.toggle_availability(@attributes.availabilities[player.id])
    @save()
  
  set_availiablity: (player, state) ->
    old_state = @attributes.availabilities[player.id]
    @attributes.availabilities[player.id] = state
    @save() unless state == old_state
  
  playing: (player) -> @set_availiablity(player, 1)
  not_playing: (player) -> @set_availiablity(player, 2)
  unconfirmed: (player) -> @set_availiablity(player, 0)
  
  #  Various methods to calculate if we have enough players
  team: -> new Team(Teams.findOne(@attributes.team_id))
  
  players: ->
    _.sortBy(@team().players(), (p) => @availability_order(p))
  
  availability_count: (state) ->
    (p for p in @players() when @availability(p) == state).length
  
  # do we: a) 0 - have sufficient players confirmed
  #        b) 1 - not know yet
  #        c) 2 - know that it's impossible to have enough players
  team_state: ->
    if @confirmations_needed() <= 0
      0
    else if @player_deficit() > 0
      2
    else
      1
  
  # this is the total number of players that we still need to confirm that they're playing
  confirmations_needed: ->
    @team().attributes.players_required - @availability_count(1)
    
  # this is the number of players we are going to need to get from outside
  player_deficit: ->
    @team().attributes.players_required - (@players().length - @availability_count(2))
  
  game_number: ->
    @team().games({date: {$lt: @attributes.date}}).length + 1