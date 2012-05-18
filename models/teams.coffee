Teams = new Meteor.Collection 'teams'
# { name: "Tom's Fault", players_required: 5, player_ids: [...] }

class Team extends Model
  @_collection: Teams
  
  valid: ->
    @errors = {}
    
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
    
    unless @attributes.players_required? and parseInt(@attributes.players_required) > 0
      @errors.players_required = 'must be a positive number'
    
    _.isEmpty(@errors)

