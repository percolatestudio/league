
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
  
  day: -> moment.weekdays[@moment.day()]
  time: -> @moment.format('h:mm a')
    
  formatted_date: -> @moment.format('Do MMMM, YYYY')
  
  clone_one_week_later: ->
    new Game(
      team_id: @attributes.team_id
      date: moment(@moment).add('weeks', 1).valueOf()
    )
  
  availability: (player) ->
    @attributes.availabilities[player.id] || 0
  
  availability_text: (player) ->
    Game.playing_states[@availability(player)]
  
  playing: (player) -> 
    @attributes.availabilities[player.id] = 1
    @save()
    
  not_playing: (player) -> 
    @attributes.availabilities[player.id] = 2
    @save()
    
  unconfirmed: (player) -> 
    @attributes.availabilities[player.id] = 0
    @save()
    