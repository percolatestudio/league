Teams = new Meteor.Collection 'teams'
# { name: "Tom's Fault", players_required: 5, player_ids: [...], 
#    logo: {lines: ["Tom's Fault"], shape: 'diamond', colors: ["#xxx", "#yyy"], font: 'Foogle'} }

class Team extends Model
  @_collection: Teams
  constructor: (attrs) ->
    super(attrs)
    @attributes.player_ids ||= []
    @prepare_logo()
  
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
    
    unless @attributes.players_required? and parseInt(@attributes.players_required) > 0
      @errors.players_required = 'must be a positive number'
    
    unless @players().length > 0
      @errors.players  = 'must not be empty'
    
    _.isEmpty(@errors)
  
  # many-many association. TODO: generalize this I guess
  players: ->
    Players.find({_id: {$in: @attributes.player_ids}}).map (player_attrs) ->
      new Player(player_attrs)
  
  games: (conditions = {}) -> 
    conditions.team_id = @id
    Games.find(conditions, {sort: {date: 1}}).map (g_attrs) -> new Game(g_attrs)
  
  future_games: -> @games({date: {$gt: moment().valueOf()}})
  
  next_game: -> @future_games()[0]
  
  player_deficit: -> if @next_game() then @next_game().player_deficit() else 0
  
  add_player: (player) ->
    # add player to this
    player.save() unless player.persisted()
    @update_attribute('player_ids', _.union(@attributes.player_ids, [player.id]))
    
    # add this to player
    player.update_attribute('team_ids', _.union(player.attributes.team_ids, [@id]))
    
    this
  
  remove_player: (player) ->
    # remove player from this
    @update_attribute('player_ids', _.without(@attributes.player_ids, player.id))
    
    # remote this from player
    player.update_attribute('team_ids', _.without(player.attributes.team_ids, @id))
    
    this
  
  create_game: (attributes) ->
    @save() unless @persisted()
    
    attributes.team_id = this.id
    Game.create(attributes)
  
  prepare_logo: (regenerate = false) ->
    if @attributes.logo? and not regenerate
      @logo = new Logo(this, @attributes.logo)
    else
      @logo = new Logo(this)
      @attributes.logo = @logo.to_object()
  
  render_small_logo: -> @logo.render('small')
  render_large_logo: -> @logo.render('large')