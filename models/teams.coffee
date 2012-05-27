Teams = new Meteor.Collection 'teams'
# { name: "Tom's Fault", players_required: 5, player_ids: [...] }

class Team extends Model
  @_collection: Teams
  constructor: (attrs) ->
    super(attrs)
    @attributes.player_ids ||= []
  
  save: (validate) ->
    players = @players()
    
    # save out all the players, and fill out the player_ids array from them
    return false unless _.all(players, (player) ->
      (player.persisted() and player.valid()) or player.save())
    
    @attributes.player_ids = (player.id for player in players)
    
    return false unless super(validate)
    
    # now that we are saved, ensure all the players have a link to our id
    for player in players
      Players.update({_id: player.id}, {$addToSet: {team_ids: @id}})
    
    return true
    
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
    @_players ||= Players.find({_id: {$in: @attributes.player_ids}}).map (player_attrs) ->
      new Player(player_attrs)
  
  add_player: (player) ->
    @remove_player(player)
    @_players.push(player)
  
  remove_player: (player) ->
    @_players = _.reject @players(), (p) -> p == player
  
  create_game: (attributes) ->
    game = new Game(attributes)
    game.team_id = this.id
    game.save()
    return game
  
  
  # destroy: ->
  #   # remove us from all players teams
  #   for player in @players()