Players = new Meteor.Collection 'players'
# { name: "Tom Coleman", email: "tom@thesnail.org", facebook_id}

class Player extends Model
  @_collection: Players
  
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    unless @attributes.name? and @attributes.name != ''
      @errors.name = 'must not be empty'
      
    # FIXME: email validator I guess
    # unless @attributes.email? and @attributes.email != ''
    #   @errors.email = 'must not be empty'
    
    unless @attributes.facebook_id? and parseInt(@attributes.facebook_id) > 0
      @errors.facebook_id = 'must be a positive number'
    
    _.isEmpty(@errors)
  
  @new_from_facebook: (facebook_data) ->
    facebook_data.facebook_id = facebook_data.id
    delete facebook_data.id
    new this(facebook_data)

  facebook_profile_url: (type = 'square') ->
    "https://graph.facebook.com/#{@attributes.facebook_id}/picture?type=#{type}"