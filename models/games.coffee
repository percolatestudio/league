
Games = new Meteor.Collection 'games'
# { team_id: 123,
#   date: 1318781876406, location: 'Brunswick',
#   availabilities: {player_id: state} }

class Game extends Model
  @playing_states = ['Unconfirmed', 'Playing', 'Not Playing']
  @_collection: Games
  constructor: (attrs) -> 
    super(attrs)
    @attributes.availabilities ||= {}
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
  
  day: -> 
    days_away = @moment.diff(moment(), 'days')
    if days_away == 0
      'Today'
    else if days_away == 1
      'Tomorrow'
    else
      moment.weekdays[@moment.day()]
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
  
  # jump through each of the states
  toggle_availability: (player) ->
    @attributes.availabilities[player.id] ||= 0 # check undefined
    @attributes.availabilities[player.id] += 1
    @attributes.availabilities[player.id] %= 3
    @save()
  
  playing: (player) -> 
    @attributes.availabilities[player.id] = 1
    @save()
    
  not_playing: (player) -> 
    @attributes.availabilities[player.id] = 2
    @save()
    
  unconfirmed: (player) -> 
    @attributes.availabilities[player.id] = 0
    @save()
  
  #  Various methods to calculate if we have enough players
  team: -> new Team(Teams.findOne(@attributes.team_id))
  
  players: ->
    _.sortBy(@team().players(), (p) => @availability_order(p))
  
  availability_count: (state) ->
    (p for p in @players() when @availability(p) == state).length
  
  player_deficit: ->
    @players().length - @availability_count(2) - @team().attributes.players_required