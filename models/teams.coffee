Teams = new Meteor.Collection 'teams'
# { name: "Tom's Fault", players_required: 5, player_ids: [...] }

class Team extends Model
  @_collection: Teams
  
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
    
    unless @attributes.players_required? and parseInt(@attributes.players_required) > 0
      @errors.players_required = 'must be a positive number'
    
    # unless @attributes.player_ids? and @attributes.player_ids.length > 0
    #   @errors.player_ids  = 'must not be empty'
    
    _.isEmpty(@errors)
  
  # we need to de-normalise and link both teams -> players and players -> teams.
  # this is due to mongo's non-relational nature 
  #   (otherwise it'd be hard to get all teams of a player or visa/versa)
  add_player: (player) ->
    return false unless player.save() and @save()
    
    player.attributes.team_ids.splice(-1, 0, @id)
    @attributes.player_ids.splice(-1, 0, player.id)
    player.save() and @save()