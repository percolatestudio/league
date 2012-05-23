playing_states = ['Unconfirmed', 'Playing', 'Not Playing']

Games = new Meteor.Collection 'games'
# { team_id: 123,
#   date: 1318781876406, location: 'Brunswick',
#   availabilities: {player_id: state} }

class Game extends Model
  @_collection: Games
  constructor: (attrs) -> 
    super(attrs)
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
      date: moment(@moment).add('days', 7).valueOf()
    )